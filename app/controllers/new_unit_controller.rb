class NewUnitController < ApplicationController
  skip_before_action :authenticate_user!

  layout "new_unit"

  def email
  end

  def confirm
    #TODO: generate & email code
    redirect_to "/new_unit/code"
  end

  def code
  end

  def check_code
    #TODO: verify code provided
    redirect_to "/new_unit/unit_info"
  end

  def unit_info
  end

  def save_unit_info
    #TODO: create user
    #TODO: create unit
    #TODO: create unit membership
    redirect_to "/new_unit/import_member_list"
  end

  def perform_import
    # TODO: import member list
    redirect_to "/new_unit/communication_preferences"
  end

  def communication_preferences
    @unit = Unit.first
  end

  def save_communication_preferences
    redirect_to "/new_unit/done"
  end

  def done
    @unit = Unit.first
  end
end
