class NewUnitController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :find_unit, except: [:email, :confirm, :unit_info]

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
    redirect_to "/new_unit/add_members"
  end

  def add_members
  end

  def perform_import
    # TODO: import member list
    redirect_to "/new_unit/weekly_digest"
  end

  def weekly_digest
  end

  def save_communication_preferences
    redirect_to "/new_unit/done"
  end

  def done
  end

  #-------------------------------------------------------------------------
  private
  
  def find_unit
    @unit = Unit.first
  end
end
