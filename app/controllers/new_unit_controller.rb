class NewUnitController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :find_unit, except: [:email, :confirm, :unit_info]

  layout "new_unit"

  def email
    redirect_to "/new_unit/unit_info" and return if current_user
  end

  def confirm
    email = params[:email]
    session[:email] = email

    code = (1..6).inject("") { |str, n| str + rand(10).to_s }

    redirect_to "/new_unit/start" and return unless email =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

    session[:login_code] = code

    UserMailer.with(code: code, email: email).new_user_email.deliver_later

    redirect_to "/new_unit/code"
  end

  def code; end

  def check_code
    redirect_to "/new_unit/user_info" and return if params[:code] == session[:login_code]

    flash[:alert] = "Invalid code"
    redirect_to "/new_unit/code"
  end

  def user_info
    email = session[:email]
  end

  def save_user_info
    email = session[:email]

    user = User.create_with(
      first_name: params[:first_name],
      last_name: params[:last_name],
      phone: params[:phone],
      nickname: params[:nickname]
    ).find_or_create_by!(email: email)

    session[:user_id] = user.id
    redirect_to "/new_unit/unit_info"
  end

  def unit_info
  end

  def save_unit_info
    user = User.find(session[:user_id])
    sign_in user
    service = NewUnitService.new(user)
    @unit = service.create(params[:unit_name], params[:location])
    redirect_to unit_welcome_path(@unit) and return if @unit
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
