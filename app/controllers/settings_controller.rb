class SettingsController < UnitContextController
  def edit
    @page_title = [current_unit.name, "Settings"]
    authorize current_unit, policy_class: UnitSettingsPolicy
  end

  def index
    authorize current_unit, :edit?
  end

  def automated_messages
    authorize current_unit, :edit?
  end

  def documents
    authorize current_unit, :edit?
  end

  def test_communications; end

  # Renders the next Weekly Digest in the browser, as the signed-in admin would receive it,
  # including any saved digest note. Nothing is sent.
  def digest_preview
    authorize current_unit, :edit?
    mail = WeeklyDigestMailer.with(unit: current_unit, recipient: current_member,
                                   digest_note_html: current_unit.digest_note_html)
                             .weekly_digest_notification
    html = (mail.html_part || mail).body.decoded
    render html: html.html_safe, layout: false
  end
end
