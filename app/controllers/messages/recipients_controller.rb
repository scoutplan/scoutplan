class Messages::RecipientsController < UnitContextController
  def index; end

  # given a key, resolve it to a collection of unit memberships
  #
  def resolve
    return unless (gid = params[:gid]).present?

    resolveable = GlobalID::Locator.locate(gid)
    @recipients = resolveable.recipients
  end
end
