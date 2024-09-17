# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class UnitMembershipsController < UnitContextController
  # before_action :find_unit, only: %i[index new create bulk_update invite]
  before_action :find_membership, except: %i[index new create bulk_update]

  def index
    authorize UnitMembership
    @current_unit_memberships = current_unit.memberships.includes(
      :user, :tags,
      { parent_relationships: { parent_unit_membership: :user } },
      { child_relationships: { child_unit_membership: :user } }
    ).order("users.last_name, users.first_name ASC")
    @page_title = current_unit.name, t("members.titles.index", unit_name: "")
    @membership = current_unit.memberships.build
    @membership.build_user
  end

  def edit
    authorize @target_membership
  end

  def new
    authorize(UnitMembership)
    @target_membership = UnitMembership.new
    @target_membership.build_user
    ap @target_membership
  end

  def show
    authorize @target_membership
    @user = @target_membership.user
    @page_title = @user.full_name
    @rsvp_events = current_unit.events.published.future.rsvp_required
    page_title [current_unit.name, @user.full_display_name]
  end

  # rubocop:disable Metrics/AbcSize
  def create
    find_or_create_user

    @member = current_unit.memberships.new(member_params)
    @member.user_id = @user.id
    return unless @member.save!

    # MemberRelationshipService.new(@member).update(params[:member_relationships])

    flash[:notice] =
      t("members.confirmations.create", member_name: @member.full_display_name, unit_name: current_unit.name)
    redirect_to unit_members_path(current_unit)
  end
  # rubocop:enable Metrics/AbcSize

  def find_or_create_user
    @user = User.create_with(
      first_name: user_params[:first_name],
      last_name:  user_params[:last_name],
      nickname:   user_params[:nickname],
      phone:      user_params[:phone]
    ).find_or_create_by!(email: user_params[:email])
  end

  def update
    ap params
    authorize(@target_membership)
    @target_membership.assign_attributes(member_params)
    update_settings_params
    return unless @target_membership.save!

    # MemberRelationshipService.new(@target_membership).update(params[:member_relationships])

    flash[:notice] = "Member information updated"
    redirect_to unit_members_path(@current_unit)
  end

  def invite
    authorize @target_membership
    @target_membership.user.invite!(current_user)
    redirect_to unit_member_path(current_unit, @target_membership), notice: "Invitation sent"
  end

  def update_settings_params
    return unless settings_params

    settings_params.each do |setting_key, values|
      values.each do |subsetting_key, subsetting_value|
        @target_membership.settings(setting_key.to_sym).assign_attributes subsetting_key.to_sym => subsetting_value
      end
    end
  end

  def pundit_user
    current_member
  end

  # POST /bulk_update
  # when Events index was in bulk mode
  def bulk_update
    member_params = params.require(:member).permit(:status, :member_type)
    params[:members].each do |member_id|
      member = UnitMembership.find(member_id)
      member.assign_attributes(member_params)
      member.save!
    end

    flash[:notice] = t("members.bulk_update.success_message")
    redirect_to unit_members_path(current_unit)
  end

  private

  def find_membership
    @target_membership = UnitMembership.includes(:parent_relationships,
                                                 :child_relationships).find(params[:member_id] || params[:id])
    @target_user = @target_membership.user
    @current_unit = @unit = @target_membership.unit
    @current_member = @unit.membership_for(current_user)
  end

  def member_params
    params.require(:unit_membership).permit(
      :status, :role, :member_type, :tag_list, :ical_suppress_declined, :roster_display_phone, :roster_display_email,
      child_relationships_attributes:  [:id, :child_unit_membership_id, :_destroy],
      parent_relationships_attributes: [:id, :parent_unit_membership_id, :_destroy],
      user_attributes:                 [:id, :first_name, :last_name, :phone, :email, :nickname]
    )
  end

  def user_params
    params.require(:unit_membership).permit(
      user_attributes: [:id, :first_name, :nickname, :last_name, :email, :phone]
    )[:user_attributes]
  end

  def settings_params
    return unless params[:settings]

    params.require(:settings).permit(
      communication: [:via_email, :via_sms, :receives_event_invitations, :receives_all_rsvps]
    )
  end
end

# rubocop:enable Metrics/ClassLength
