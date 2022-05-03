# frozen_string_literal: true

# a Texter for sending digests
class DigestTexter < MemberTexter
  include RsvpHelper

  def body_text
    renderer.render(
      template: "member_texter/digest",
      format: "text",
      assigns: {
        member: @member,
        service: RsvpService.new(@member),
        events: events,
        open_rsvps: open_rsvps(@member)
      }
    )
  end

  private

  def events
    @member.unit.events.published.this_week
  end
end





# - content_for :left_column do
#   - if (unresponded_count = service.unresponded_events.count).positive?
#     = magic_link_to \
#       @member,
#       unit_url(@unit),
#       style: "display:block;margin-bottom:1rem;color:#E66425;font-weight:bold;text-decoration:none;" do
#         div(style="padding-left:1.5rem;text-indent:-1.5rem;")
#           <img style="height:1rem;position:relative;top:2px;margin-right:0.3rem;" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEgAAABACAYAAAC5vjEqAAAACXBIWXMAABYlAAAWJQFJUiTwAAADOklEQVR4nO2c7XHaQBBAHxo3ACXIJSglkBLowAMlQAlQApQQSgglhBLi3/5lSkh+SLIVoY/72NsVE78Zz2BZFqcnae9ub2H29rJgIqyAvHr9CpwN2/LBk3UDgDWwB+at7TdgB5zUW9Qgs3xzYAscuZdDte1Y7WOGpaAl5Z0zxr7a1wRLQS5yQvYVxUrQGig89i+q/1HHQtCcsDuiK5Anx0LQlrATnWMQsLUFFcSd5Ba/RzMabUESwVY1YGsKWiHTXS+rY6mgJSg0MPehFrC1BK35nGdJkKPU7WsIyknT+2yRld6JhqBUj4P0Y9tJakGpA6pU4O8ldbrD5wqfgEv1eol7jDkCzz6N8iGlIJ9B3Q44NH4/UybNXATXMe4wtmMIs0QZxTnwG7fYcwW+9fztF26Sb5R30c2pdR6kikE+gXnopK6Ox0gWsFMIkkxNvHrs65tCcSKFILPkVor3lha0xjA9il/v54SkIJN8TQeiA1NJQdLzrVDmCN5FUoJybGNPmz1CF0tK0FHoOJKItElC0BLbwNyHSLskBE3x7qmJblusIJWcTATRuagYQVPp1seIuogxgkwW8gKIupChgsRHrIkJHuGHCnqER6tN0DgtRJD1fCuUoCyDryCVRHlCvOOmr6DQwoOp4B2wfQSlWt8aIsXF8Or2fQSlGjEPSUhVyeF8Lq6CUq4/FT3H7tsugfN6naug1IH5B//GtzXwM/F7OgVsF0Ea8626d3wH/tBfGiyJUwHEmCCLwKzJ6MUfE/Qo861QRsd1Q4JUK7kMGeyAhgRpj5hvlMULFxIsIY/Qe659grSrSXfAAvhe/SyqbVr0Vt92CdJOhLUrO2oO6ErqnEZ1CdKcb70yXLZywG99PobOgN0WFFvo7ctlfBfnCg8J7gog2oKmmMowDdhNQcnr/Tpw6QhUP3pAK51cC7JKhBUMj7VW6AuCRhyuBVkWHhzplrTCblHyY542e3tZ5JT1hNZc+fyks9Wd0+b5ielMRgumIaXJNuMxVyi0WGZMe23dmjxDf5zxSNwyJvIVEBPl/CVomHNGOR/aWLdkgmyASz1QPFUbvuJR6WBD9aUqXR9maX5Nzf/G3dfy/AXgDX2R2qJIMQAAAABJRU5ErkJggg==" />
#           = t("unanswered_rsvps", count: unresponded_count)
#           |&nbsp;
#           span(style="white-spaces:nowrap; text-decoration:underline;")
#             = "Click to respond."