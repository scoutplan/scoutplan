class Messages::RecipientsController < UnitContextController
  def index; end

  # given a key, resolve it to a collection of unit memberships
  #
  def resolve
    return unless (gid = params[:gid]).present?

    resolveable = GlobalID::Locator.locate(gid)
    @recipients = MessageRecipient.with_guardians(resolveable.recipients)
  end

  def resolve_tag
    return unless (tag_name = params[:tag_name]).present?

    recipients = current_unit.unit_memberships.tagged_with(tag_name).select(&:contactable?)
    @recipients = MessageRecipient.with_guardians(recipients)
  end
end
