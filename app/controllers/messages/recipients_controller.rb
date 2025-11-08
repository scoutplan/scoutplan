class Messages::RecipientsController < UnitContextController
  def index; end

  # given a key, resolve it to a collection of unit memberships
  #
  def resolve
    return unless (gid = params[:gid]).present?

    # we can't use GlobalID to resolve tags, so handle that case separately
    if gid.start_with?("tag://")
      @recipients = current_unit.unit_memberships.tagged_with(gid.delete_prefix("tag://")).select(&:contactable?)
    else
      resolveable = GlobalID::Locator.locate(gid)
      @recipients = MessageRecipient.with_guardians(resolveable.recipients)
    end
  end
end
