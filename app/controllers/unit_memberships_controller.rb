# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class UnitMembershipsController < UnitContextController
  # before_action :find_unit, only: %i[index new create bulk_update invite]
  before_action :find_membership, except: %i[index new create bulk_update email_availability]

  def index
    authorize UnitMembership
    @current_unit_memberships = current_unit.memberships.includes(
      :user, :tags,
      {parent_relationships: {parent_unit_membership: :user}},
      {child_relationships: {child_unit_membership: :user}}
    ).order("users.last_name, users.first_name ASC")
    @page_title = current_unit.name, t("members.titles.index", unit_name: "")
    @membership = current_unit.memberships.build
    @membership.build_user
  end

  def edit
    authorize @target_membership
    @family_members = load_family_members
    @child_ids = @target_membership.children.pluck(:id).to_set
    @parent_ids = @target_membership.parents.pluck(:id).to_set
  end

  def new
    authorize(UnitMembership)
    @target_membership = UnitMembership.new
    @target_membership.build_user
  end

  def show
    authorize @target_membership
    @user = @target_membership.user
    @page_title = @user.full_name
    page_title [current_unit.name, @user.full_display_name]
  end

  def create
    authorize UnitMembership

    @target_membership = build_membership

    if already_a_member?
      @target_membership.errors.add(:base, t("members.errors.already_a_member", email: submitted_email))
      return render :new, status: :unprocessable_entity
    end

    if @target_membership.save
      flash[:notice] = t("members.confirmations.create",
        member_name: @target_membership.full_display_name,
        unit_name: current_unit.name)
      redirect_to unit_members_path(current_unit)
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET .json — is this address free to add to this unit?
  def email_availability
    authorize UnitMembership, :create?

    email = params[:email].to_s.strip
    taken = email.present? && current_unit.memberships.joins(:user).exists?(users: {email: email})

    render json: {
      available: !taken,
      message: (taken ? t("members.errors.already_a_member", email: email) : nil)
    }
  end

  def update
    authorize(@target_membership)
    @target_membership.assign_attributes(member_params)
    update_settings_params

    if @target_membership.save
      flash[:notice] = "Member information updated"
      redirect_to unit_members_path(@current_unit)
    else
      render :edit, status: :unprocessable_entity
    end
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

  def load_family_members
    scope = current_unit.unit_memberships.excluding_inactive.joins(:user)
    same_name = scope.where("users.last_name = ?", @target_membership.last_name).order(:first_name)
    others = scope.where.not("users.last_name = ?", @target_membership.last_name).order(:last_name, :first_name)
    same_name + others
  end

  def find_membership
    @target_membership = UnitMembership.includes(:user, :tags,
      parents: :user,
      children: :user).find(params[:member_id] || params[:id])
    @target_user = @target_membership.user
    @current_unit = @unit = @target_membership.unit
    @current_member = @unit.membership_for(current_user)
  end

  def submitted_email
    user_params&.dig(:email).to_s.strip
  end

  # An address already in the system belongs to an existing User, so reuse it
  # rather than trying to create a second account on a unique column. Two
  # parents sharing an address is the common case here.
  def find_or_build_user
    attrs = user_params || {}
    existing = User.find_by(email: submitted_email) if submitted_email.present?
    return existing if existing

    User.new(attrs.slice(:first_name, :last_name, :nickname, :phone, :email))
  end

  def build_membership
    membership = current_unit.memberships.new(member_params.except(:user_attributes))
    membership.user = find_or_build_user
    membership
  end

  # UnitMembership validates uniqueness of user scoped to unit, but the default
  # message ("User has already been taken") does not tell an organiser that the
  # address they typed belongs to someone already on the roster.
  def already_a_member?
    user = @target_membership.user
    user&.persisted? && current_unit.memberships.exists?(user_id: user.id)
  end

  def member_params
    params.require(:unit_membership).permit(
      :status, :role, :member_type, :ical_suppress_declined, :roster_display_phone, :roster_display_email,
      child_relationships_attributes: [:id, :child_unit_membership_id, :_destroy],
      parent_relationships_attributes: [:id, :parent_unit_membership_id, :_destroy],
      user_attributes: [:id, :first_name, :last_name, :phone, :email, :nickname],
      tag_list: []
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
