# Family & RSVP Rules

**Status:** Draft. D1, D2, D4, D8 and D9 decided; D3 and D6 decided with one open question each; the rest open (see §3).
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

- **Household:** a named group of members in a unit.
  - Every member belongs to **exactly one** household. An adult with no family in the unit is a household of one.
  - Admins create and maintain households, as they maintain relationships today. It's a one-time setup per family.
  - Split households are rare and one side usually runs the calendar, so there is no multi-household membership. If it's ever needed, an explicit cross-household grant can be added later (§6).
- **Point of contact:** a flag on an adult member, meaning "keeper of this household's calendar".
  - A household normally has one; it may have two.
  - The flag decides who is *expected to pay attention*: nags, approval requests and answer notices go to points of contact.
  - It does **not** decide who is *allowed* to answer.
- **Answerable(actor):** the members `actor` may answer for:
  - An **adult:** everyone in their household, including other adults.
  - A **youth:** themselves only, and only when self-RSVP is enabled for them (D3).
  - An **admin or organizer:** anyone in the unit.
- **RSVP:** one row per (event, member):
  - `answer`: `yes` or `no`
  - `respondent`: who submitted it
  - `approval`: `not_required`, `pending` or `approved`
  - `approved_by` and `approved_at`: set when approved

Today's one-way links encoded "who is expected to pay attention" as if it were "who may answer". This model separates the two. The links' intent survives as the point-of-contact flag (see §4.2 for how it's derived).

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
- returns what was saved and what was refused, with reasons, so nothing fails silently
- triggers **one** set of messages per submission (D9)

### 2.4 One read model

```
HouseholdRsvp.new(household, event)
```

For each member it gives:
- the answer and approval state
- **who answered and when**, shown on the event page as "Going · answered by Dad, Tue"
- whether they still need an answer

It also produces the household's summary sentence. It replaces the five objects listed in §1.7.

---

## 3. Decisions

Each item records a decision, or a recommendation awaiting one. Status is either **Decided** or **Open**.

### D1. What is a family? — **Decided**

A household, as in §2.1: one per member, managed by admins, with one or two points of contact.

### D2. Who may answer for whom? — **Decided**

- Any adult in a household may answer for anyone in that household. This includes other adults: dad can answer for mom, and mom for dad.
- A youth answers only for themselves, and only with self-RSVP enabled.
- Admins and organizers may answer for anyone. Their answers don't need approval, e.g. attendance recorded at the trailhead.
- A dad's answer counts immediately. Points of contact are **informed, not asked to approve** (D9).

### D3. How is youth self-RSVP enabled? — **Decided, with one open question**

- Two switches:
  1. the unit enables the feature
  2. an adult in the youth's household enables it for that youth
- **The per-event `events.allow_youth_rsvps` flag is dropped.** No UI or controller has ever set it: `EventsController` doesn't permit it and no event form renders it. So every event has carried the default `true`, and dropping it changes no behavior. *Before dropping the column, check for rows set to `false` by hand.*
- **Open:** must the youth be reachable by email or SMS? Proposed: yes, either one. Today the toggle requires email.

Usage is believed to be low. The feature is **kept on purpose**, because it encourages youth to take ownership of their participation.

### D4. What does a youth's answer mean? — **Decided**

- A youth's **"yes"** is an **expression of interest**. It is pending until an adult in their household approves it (D6).
- A youth's **"no"** takes effect **immediately, without approval**, and the household's points of contact are notified (D9).
- So the pending state only ever applies to a youth's "yes". The current `declined_pending` state goes away. Existing `declined_pending` rows become plain `declined` in the backfill (§4.2).

### D5. How does a pending answer count? — **Open**

| Question | Proposed |
|---|---|
| Responded, for nags and "household complete" | **Yes.** Don't nag about a youth who answered; the approval request is the prompt. |
| Shown on the organizer roster | **Yes, marked "tentative".** |
| Counts toward the headcount cap | **Yes (holds a seat),** so approval can't overfill the event. |
| Counts toward minimum headcount | **No,** until approved. |
| Summary sentence | **"Sam wants to go (awaiting approval)".** Never treat it as declined. |

### D6. How does approval work? — **Decided, with one open question**

- **Only adults in the youth's household may approve.** That's a change: today admins and organizers can approve too.
- Approval is an explicit Approve/Decline action, available from:
  - the event page
  - one-tap links in the approval email
  - an SMS reply
- **Re-submitting the household form no longer approves anything implicitly.**
- The approval request is often the parent's first sight of the event, so it **reads like an invitation**: "Sam wants to go to the Fall Campout (Nov 21–23). Approve or decline?" It includes the event details: dates, location, cost and organizer.
- If an adult changes the youth's answer, that's their own answer and needs no approval.
- **Open:** what happens when an adult declines a youth's request?
  - (a) **Proposed:** the youth's RSVP becomes "no", and the youth is told.
  - (b) The youth is left unanswered.

### D7. What happens when an answer changes after approval? — **Open**

- **Proposed:** a youth changing an approved answer makes it pending again.
- **Proposed:** a youth can't change an answer an adult made; they see it read-only.

### D8. Who gets nagged and reminded? — **Decided**

- **Weekly nag and last call go to points of contact only**, as **one message per household** that lists every member still unanswered.
- Other adults get no nags.
- A youth with self-RSVP enabled is **not** nagged separately. The household nag covers them, and a youth who answers stops the nag for themselves.
- Inactive members are excluded everywhere, as today.

### D9. Who hears about an answer? — **Decided**

The rule: **points of contact get a message for every household answer.**

| Who answered | Points of contact get | The respondent gets | Others |
|---|---|---|---|
| A point of contact | A **confirmation** | (same person) | The other point of contact, if any, gets a notice |
| Another adult in the household | A **notice**: "Dad RSVP'd Dad and Sam: Going to the Fall Campout" | A confirmation | An adult answered for by someone else gets a notice that it's about them |
| A youth says "yes" | The **approval request** (D6) | A "request sent" confirmation | — |
| A youth says "no" | A **notice**: "Sam said they can't make the Fall Campout" | A confirmation | — |
| An admin or organizer | A notice | — | — |
| Anyone, by SMS reply | The same as on the web | The same as on the web | — |

- **Changes are called out.** When an answer replaces one someone else made, the message says so: "Dad changed Sam's RSVP from Going to Regrets."
- **One message per recipient per submission**, never one per person answered for.
- Siblings are never copied.

### D10. What does an SMS "yes" or "no" apply to? — **Open**

- **Proposed:** the SMS prompt lists the names it covers, and the reply applies to exactly those names. That's the texter's unanswered Answerable members.
- Prompts normally go only to points of contact (D8). If another adult texts "upcoming", their prompt lists the household too.
- The reply-to-the-reply confirms the names it applied to.

### D11. Notes — **Open**

- **Proposed:** keep one note per submission, stored on each row, as now.

### D12. Messages to youth members — **Open** *(new: messaging also uses the relationship links)*

Today a message to a youth is also delivered to their contactable "parents" (`Message::Notifiable`, `MessageService`, `MessageRecipient`). If mom is linked to the kid and dad is linked only through mom, today only mom gets copied.

Options:
- (a) **Proposed:** copy the household's points of contact. This matches today's mom-only behavior in the common case.
- (b) Copy every adult in the household.

Youth contactability (`contactable_guardian?`) becomes "the household has a contactable point of contact".

---

## 4. Data changes

### 4.1 Schema

1. A new table `households`:
   - `id`, `unit_id`, `name` (defaults to the members' last names, e.g. "Smith / Jones")
   - timestamps
   - `has_paper_trail`
2. On `unit_memberships`:
   - add `household_id`, not null after the backfill
   - add `point_of_contact` (boolean, default false)
   - Validation: a household's members are in its unit, and each household has at least one adult point of contact. Violations show as admin warnings rather than hard errors during the transition.
3. On `event_rsvps`:
   - Add `approval` (integer enum: `not_required` 0, `pending` 1, `approved` 2), plus `approved_by_id` and `approved_at`.
   - Narrow `response` to `accepted`/`declined`, keeping integers 1 and 0.
   - Drop `approved`.
4. On `event_rsvps`, add indexes:
   - a **unique** index on `(event_id, unit_membership_id)`, after checking for and merging duplicates
   - indexes on `unit_membership_id` and `respondent_id`
5. Drop `events.allow_youth_rsvps` (D3), and remove its use in `EventRsvpPolicy#create?` and the specs and factories that set it.
6. Drop `user_relationships` and `UserRelationshipsPolicy`.
7. Keep `member_relationships` until the cutover, then drop it.

### 4.2 Backfill

1. **Households:** for each unit, follow the `member_relationships` links all the way through to find each connected group. Each group becomes one household, and every unlinked member becomes a household of one. Split households are rare, so this grouping is right for nearly all real data.
2. **Points of contact:** within each household, an adult is a point of contact if they have outgoing links (they answer for someone) and no other adult answers for them.
   - Mom → dad, mom → kid: mom is the point of contact.
   - Both parents → kid, with no link between them: both are.
   - An adult in a household of one is that household's point of contact.
3. **RSVPs:**
   - `accepted_pending` (3) becomes `accepted` with `approval = pending`.
   - `declined_pending` (2) becomes `declined` with `approval = not_required` (D4: a youth's "no" needs no approval).
   - Every other row gets `not_required`.
4. **Admin review report** listing households that have:
   - no clear point of contact
   - more than two points of contact
   - more than two adults
   - adults who don't share all the children
   - links in both directions between two adults

**Before migrating:** run a read-only version of steps 1–2 against production and review the report. That shows how much the automatic backfill gets right.

---

## 5. Code changes

| New | Replaces |
|---|---|
| `Household` model, plus admin UI to manage households and points of contact | `MemberRelationship`, `MemberRelationshipsController`, `RelationshipCandidatesController`, `MemberRelationshipService`, `UnitMembership#family`/`#parents`/`#children`/`#siblings`, `FamilyPresenter` |
| `RsvpRules.decide` | `EventRsvpPolicy#create?`/`#approve?` internals, `EventRsvp#requires_approval?`, `enforce_approval_policy`, `response_allowed?` |
| `RsvpRecorder` | Write logic in `FamilyRsvpsController`, `EventRsvpsController#create/update`, `SmsResponseService#process_rsvp`, `RsvpService#record_*`, `EventResponseService` |
| `HouseholdRsvp` (read model) | `FamilyRsvp`, `RsvpService` (RSVP parts), `FamilyMemberRsvp`, `FamilyEventRsvps` |
| An RSVP-submission notifier implementing D9 | Per-row `EventRsvp::Notifiable#enqueue_confirmation`, the presenters in `EventRsvpConfirmationMailer` |
| An approval request notifier and an approve/decline endpoint (D6) | The dead `_edit_rsvp_section` / `create_batch_member` path |
| Household-based nag (D8) | Per-member loop in `RsvpNagJob`; individual `RsvpLastCallJob` recipients |
| Household-based youth contactability and message copying (D12) | `contactable_guardian?`, `ComputeChildContactabilityJob`, the `parents` uses in messaging |

### Order of work

1. Remove the dead code (§1.7) and add the indexes. This is safe whatever is decided.
2. Run the read-only household backfill report against production, and review it.
3. Add `Household` and the point-of-contact flag, backfill them, and build the admin UI. Run it alongside the old links.
4. Write `RsvpRules`, with a decision-table spec, and the RSVP data migration.
5. Write `RsvpRecorder` and move the write paths onto it one at a time: web form, organizer, SMS.
6. Write `HouseholdRsvp` and move the read paths onto it.
7. Switch the messages: D9 confirmations and notices, D6 approval, D8 nags.
8. Move messaging and contactability onto households (D12).
9. Delete the old objects and drop `member_relationships`.

The specs in `spec/` describe today's behavior. Update the ones that conflict with these decisions on purpose, rather than treating them as regressions.

---

## 6. Deferred

- **Cross-household grants:** letting an adult outside a household answer for a member of it, such as a grandparent or the parent in the second home. This can be added if a real case appears.
- **Parent-managed households:** households stay admin-managed. Parents' self-service can come later.
