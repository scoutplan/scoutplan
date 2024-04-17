class UnitMembershipRequestsController < ActionController::Base
  layout "public"

  def new; end

  def create
    @request = UnitMembershipRequest.new(unit_membership_request_params)
  end

  private

  def unit_membership_request_params
    params.require(:unit_membership_request).permit(:unit_id, :first_name, :last_name, :email, :phone)
  end
end
