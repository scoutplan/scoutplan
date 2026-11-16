# Family & RSVP Rules

**Status:** Draft. Decisions pending (see §3).
**Scope:** Who belongs to a family, who may answer for whom, youth self-RSVP and approval, and who gets nagged, reminded and confirmed.
**Out of scope:** Payments (being removed), event shifts, guests, the headcount feature beyond how pending answers count.

Once the decisions in §3 are made, this document becomes the source of truth. The refactor implements it, and a decision-table spec (`spec/models/rsvp_rules_spec.rb` or similar) mirrors it line for line.

---

## 1. Current behavior (as read from the code, November 2026)

This section describes what the code *does*, not what it should do. It is drawn from reading the code, not from running it.

### 1.1 Family

- There is no family entity. `UnitMembership#family` (`app/models/unit_membership.rb:96`) is computed from each member's point of view as `children | parents | siblings`, where siblings are the parents' other children.
- So the relationship is **asymmetric**:
  - A parent's family is their children.
  - A child's family is their parents and siblings, half-siblings included.
- **Co-parents are not in each other's family.** Nothing links two adults except a shared child, and `family` doesn't follow that link.
- About 27 call sites use `family`, for three different purposes:
  - deciding who appears on the RSVP form
  - deciding whether "the family has fully responded"
  - building summary sentences such as "Alice and you are going"

### 1.2 Who may answer

`EventRsvpPolicy#create?` (`app/policies/event_rsvp_policy.rb:27`) says:

1. Admins, unit organizers and event organizers may answer for anyone.
2. A member may answer for their `children`. This includes children who are *adults*.
3. An adult may answer for themselves.
4. A youth may answer for themselves only if all three flags are true:
   - `units.allow_youth_rsvps` (default **false**)
   - `events.allow_youth_rsvps` (default **true**)
   - `unit_memberships.allow_youth_rsvps` (default **false**). A guardian sets this on the youth's profile, and the toggle is disabled unless the youth has an email address.

Enforcement is unusual:
- The policy is called from a **model validation** (`event_rsvp.rb:24`).
- `FamilyRsvpsController#create` never calls `authorize`.
- An unauthorized answer fails validation and is **silently dropped**: the controller only collects RSVPs that saved.
- On the family form, the Going/Regrets radio buttons aren't disabled by policy (only the shift switches are). A youth sees their parents' rows and can submit answers for them, which then fail silently.

### 1.3 RSVP state and approval

- `response` mixes the answer with approval status. Its values are `accepted` (1), `declined` (0), `accepted_pending` (3) and `declined_pending` (2).
- A `before_save` callback (`event_rsvp.rb:15`) rewrites `accepted` to `accepted_pending` and `declined` to `declined_pending` whenever the **respondent** is a youth.
- `approved` (boolean) **never becomes true**. The only assignment (`event_rsvp.rb:120`) runs right after the response has been forced to pending.
- **Approval happens implicitly.** A guardian reopens the family form, where the youth's row shows "pending your approval", and resubmits. The respondent becomes the guardian and the response changes to plain `accepted`/`declined`. So any guardian submission silently approves every pending row on the form.
- An explicit "Approve and Send" UI exists (`events/partials/show/_edit_rsvp_section.slim`), but it's unreachable: its route is commented out (`config/routes.rb:221`) and it posts to `create_batch_member`, which doesn't exist.

### 1.4 How pending answers count

| Question | Treatment of `*_pending` | Where |
|---|---|---|
| Has this member responded? | Yes (any row counts) | `FamilyRsvp#status`, `RsvpService#family_fully_responded?` |
| Is the family "fully declined"? | A pending *accept* counts as **not accepted**, so a family can show as fully declined | `family_rsvp.rb:80`, `rsvp_service.rb:67` |
| Does it count toward the headcount cap? | No (`rsvps.accepted` only) | `event.rb:212` |
| Does it count toward minimum youth headcount? | No | `event.rb:436` |
| Does the form show the answer as checked? | Yes | `_edit_rsvp_fields.html.erb` |

### 1.5 Nags, last call, confirmations

- **Weekly nag** (`RsvpNagJob`) loops over **every** unit membership. For each contactable member whose family isn't fully responded on the next open event, it sends that member a nag. A family of four can therefore produce up to four nags about the same event. Whether a youth's nag is also routed to their parents needs checking in the notifier/recipient code.
- **Last call** (`RsvpLastCallJob`) goes to `event.non_respondents`: every active member individually, with no family grouping.
- **Confirmation** (`EventRsvp::Notifiable`) is sent **per RSVP row**, not per submission.
  - Recipients are normally the member alone.
  - When approval is required, recipients are the member's whole `family`, siblings included. The code comment there reads "code smell".
  - A guardian answering for three children therefore gets three confirmations.

### 1.6 SMS replies

`SmsResponseService` handles a "yes" or "no" reply:
- The answer applies to **every active member of the texter's family**.
- For a youth texter, that includes their parents. Those rows fail validation and are silently dropped.
- An existing RSVP is updated without changing `respondent`, so the record keeps whoever answered first.

### 1.7 Duplicated and dead code

- Five objects cover one idea:
  - `FamilyRsvp`
  - `RsvpService`
  - `FamilyMemberRsvp`
  - `FamilyPresenter`
  - `FamilyEventRsvps` (dead: broken constructor, refers to an association that doesn't exist)
- `family_responses_in_words` exists twice. The copy in `FamilyRsvp` is broken: line 89 doesn't filter by response.
- `EventResponseService` has no callers and would raise `ArgumentError` if called (`process_response` takes 2 arguments but is called with 1).
- `RsvpService#record_family_response` has no callers. It would record each child as their own respondent, which would make their answers pending.
- `UnitMembership#recipients` is missing a `return` on `[self] if adult?`.
- `puts "I am here"` is left in `event_rsvp.rb:114`.
- `user_relationships` table: no model, only an orphaned policy.
- `event_rsvps` has **no database indexes**, including no unique index on `(event_id, unit_membership_id)`. Uniqueness is enforced only by a validation, which concurrent requests can race past.

---

## 2. Proposed model

### 2.1 Concepts

- **Guardianship:** a directed edge from a guardian to a youth, stored in `member_relationships` as today. Edges only make sense from an adult to a youth.
- **Household:** the set of members connected through guardianship edges (the connected component of the guardianship graph). Co-parents are in the same household because they share a child. Computed once per request as a value object, not stored. *(See D1.)*
- **Dependents(m):** the youth members that `m` is a guardian of.
- **Answerable(actor):** the members `actor` may answer for:
  - themselves, if adult, or if youth with self-RSVP enabled
  - their Dependents
  - anyone, if admin or organizer
- **RSVP:** one row per (event, member), with four fields:
  - `answer`: `yes` or `no`
  - `respondent`: who submitted it
  - `approval`: `not_required`, `pending` or `approved`
  - `approved_by` and `approved_at`: set when approved

### 2.2 One decision point

```
RsvpRules.decide(actor:, member:, event:) -> Decision(allowed?, approval_required?, reason)
```

Every write path calls this and nothing else to decide: the web form, organizer edits, SMS replies and email links. The policy delegates to it, and the model no longer performs authorization.

### 2.3 One write path

```
RsvpRecorder.record(actor:, event:, answers: { member => :yes | :no | :clear }, note:)
```

The recorder:
- calls `decide` for each member
- writes all answers in one transaction
- returns a result that lists what was saved and what was refused, with reasons, so nothing fails silently
- sends **one** confirmation per submission

### 2.4 One read model

```
HouseholdRsvp.new(household, event)
```

It answers, for each member:
- their answer
- their approval state
- who may answer for them
- whether they still need an answer

It also produces the summary sentence. It replaces the five objects listed in §1.7.

---

## 3. Decisions

Each decision gives the question, the options, a recommendation and today's behavior. **Bold** marks the recommendation. Change anything you disagree with.

### D1. What is a family?

- **(a) Household = connected component through guardianship.** Co-parents are included; an adult with no dependents is a household of one; no new table.
- (b) An explicit `households` table that admins manage. Handles split households precisely (e.g. a child who lives in two homes), but costs data entry and admin UI.
- (c) Keep today's per-person view.

*Edge case for (a):* with divorced parents who each have new partners in the unit, the component can join two homes through the shared child. That's correct for the shared child. It's only odd if the households also contain unrelated children of the new partners, which is probably rare in one unit.

Today: (c), asymmetric, co-parents excluded.

**Decision:** ______

### D2. Who may answer for whom?

- Adults answer for themselves and their dependents. **Guardians answer only for youth dependents, not adult children.**
- **A co-parent may not answer for the other adult**, but sees that adult's answer.
- Admins and organizers may answer for anyone, and **their answers never need approval.**

Today: the same, except a "parent" can answer for an adult child, and co-parents can't see each other's answers.

**Decision:** ______

### D3. How is youth self-RSVP enabled?

Options:
- **(a) Unit setting plus a guardian's per-youth toggle.** Drop the per-event flag.
- (b) Keep all three flags.
- (c) Unit setting plus guardian toggle, plus an organizer opt-*out* per event (default allowed).

Sub-question: should the guardian toggle require the youth to have an email address? Today it's disabled without one. **Recommend: require the youth to be reachable by email or SMS.**

Today: three flags, defaulting to unit off, event on, member off.

**Decision:** ______

### D4. What needs approval?

Options:
- **(a) Every youth self-answer, yes or no, needs one guardian's approval.**
- (b) Only "yes" answers need approval; "no" is final.
- (c) Guardians choose per youth: "needs approval" or "trusted".

Today: (a).

**Decision:** ______

### D5. How does a pending answer count?

| Question | Recommendation |
|---|---|
| Responded, for nags and "family complete" | **Yes.** Don't nag a youth who answered. |
| Shown on the organizer roster | **Yes, marked "tentative".** |
| Counts toward the headcount cap | **Yes (holds a seat),** so approval can't overfill the event. |
| Counts toward minimum headcount | **No,** until approved. |
| Summary sentence | **"Sam is going (awaiting approval)".** Never treat it as declined. |

Today: see the table in §1.4. Pending is inconsistent and sometimes counts as declined.

**Decision:** ______

### D6. How does approval work?

- **An explicit Approve/Reject action**, available from the event page, a link in the approval-request email, and an SMS reply.
- **Any one guardian may approve.** Admins and organizers may too.
- If a guardian changes the youth's answer, that counts as the guardian's own answer and needs no approval.
- **Re-submitting the family form no longer approves anything implicitly.**
- If a pending answer is rejected:
  - (a) **the youth is left unanswered and the guardian is prompted to answer**, or
  - (b) the answer is flipped.

Today: approval is implicit through resubmitting, and the explicit UI is dead code.

**Decision:** ______

### D7. What happens when an answer changes after approval?

- **A youth changing an approved answer makes it pending again.**
- **A guardian's answer is final** unless a guardian, admin or organizer changes it.
- Can a youth change an answer a guardian made? **Recommend: no.** The youth sees it read-only.

Today: undefined in practice. A youth's change goes pending, and the guardian-versus-youth precedence isn't handled.

**Decision:** ______

### D8. Who gets nagged and reminded?

- **Weekly nag:** **one message per adult.** It covers the members that adult can answer for who still need an answer: the adult and their dependents. A youth with self-RSVP who hasn't answered gets their own nag. Co-parents each get a nag about shared dependents. **Alternative:** nag only one guardian per household, but there's no good rule for choosing which.
- **Last call:** the same grouping, with the same rules.
- **Inactive members:** excluded everywhere, as today.

Today: per member, with possible duplicates; last call goes to individuals.

**Decision:** ______

### D9. Who gets confirmations?

- **One confirmation per submission, not per row.** It goes to the respondent and lists everyone they answered for.
- **Guardians of any youth in the submission are copied**, whoever answered. When approval is needed, the guardians get the approval-request version instead.
- **Siblings are never copied.**

Today: per row, and to the whole family including siblings when approval is involved.

**Decision:** ______

### D10. What does an SMS "yes" or "no" apply to?

- **(a) Everyone in Answerable(texter) who hasn't answered yet**, and the reply SMS lists the names.
- (b) Everyone in Answerable(texter), overwriting existing answers.
- (c) Only the texter.

A youth texter's own answer follows D4.

Today: every active family member of the texter, including a youth's parents (which fails).

**Decision:** ______

### D11. Notes

The family form has one note field, which is copied onto every RSVP in the submission. Options:
- **(a) Keep one note per submission, stored on each row**, as now.
- (b) One note per member.

**Decision:** ______

---

## 4. Data changes

1. On `event_rsvps`:
   - Add `approval` (integer enum: `not_required` 0, `pending` 1, `approved` 2), plus `approved_by_id` and `approved_at`.
   - Narrow `response` to `accepted`/`declined`, keeping integers 1 and 0 so existing rows stay valid.
2. Backfill:
   - `accepted_pending` (3) becomes `accepted` with `approval = pending`.
   - `declined_pending` (2) becomes `declined` with `approval = pending`.
   - Every other row gets `not_required`.
3. Drop `event_rsvps.approved`.
4. Add indexes:
   - a **unique** index on `(event_id, unit_membership_id)`, after checking for and merging duplicates
   - an index on `unit_membership_id`
   - an index on `respondent_id`
5. Depending on D3, drop `events.allow_youth_rsvps`.
6. Drop the `user_relationships` table and `UserRelationshipsPolicy`.
7. Optionally add a check that `member_relationships` edges go from an adult to a youth, depending on D2.

---

## 5. Code changes

| New | Replaces |
|---|---|
| `Household` (value object) | `UnitMembership#family`, `#siblings`, `FamilyPresenter` |
| `RsvpRules.decide` | `EventRsvpPolicy#create?` internals, `EventRsvp#requires_approval?`, `enforce_approval_policy`, `response_allowed?` |
| `RsvpRecorder` | Write logic in `FamilyRsvpsController`, `EventRsvpsController#create/update`, `SmsResponseService#process_rsvp`, `RsvpService#record_*`, `EventResponseService` |
| `HouseholdRsvp` (read model) | `FamilyRsvp`, `RsvpService` (RSVP parts), `FamilyMemberRsvp`, `FamilyEventRsvps` |
| A single confirmation notifier per submission | Per-row `EventRsvp::Notifiable#enqueue_confirmation` |

Order of work:
1. Remove the dead code (§1.7).
2. Add the indexes.
3. Write `RsvpRules`, with its decision-table spec.
4. Run the data migration.
5. Write `RsvpRecorder` and move the write paths onto it one at a time.
6. Write `HouseholdRsvp` and move the read paths onto it.
7. Change nags and confirmations.
8. Delete the old objects.

The specs in `spec/` describe today's behavior. Update the ones that conflict with these decisions on purpose, rather than treating them as regressions.
