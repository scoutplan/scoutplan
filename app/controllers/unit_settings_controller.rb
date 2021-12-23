# frozen_string_literal: true

class UnitSettingsController < UnitContextController
  layout 'application_new'
  before_action :find_unit

  def edit
    @page_title = [@unit.name, 'Settings']
    # if @unit.settings(:communication).digest_schedule
    #   @schedule = IceCube::Schedule.from_yaml(@unit.settings(:communication).digest_schedule)
    # end
    authorize @unit, policy_class: UnitSettingsPolicy
  end

  def update
    @unit.update(unit_params) if params[:unit].present?
    @unit.settings(:utilities).fire_scheduled_tasks = true if params.dig(:settings, :utilities, :fire_scheduled_tasks)
    ap params.dig(:settings, :communication, :digest_schedule)
    @unit.settings(:communication).digest_schedule = params.dig(:settings, :communication, :digest_schedule)
    @unit.save!
    redirect_to edit_unit_settings_path(@unit)
  end

  def pundit_user
    @current_member
  end

  private

  def find_unit
    @current_unit = @unit = Unit.find(params[:id])
    @current_member = @unit.membership_for(current_user)
  end

  def unit_params
    params.require(:unit).permit(:name, :location, :logo, settings: [:communication, :utilities])
  end

  def set_digest_schedule
    Sidekiq.set_schedule(
      digest_schedule_key,
      cron: '0 7 * * sun',
      class: 'DigestSender',
      args: @unit.id
    )
  end

  def set daily_reminder_schedule_key
  end

  def digest_schedule_key
    "send_digests_#{@unit.name.parameterize.underscore}"
  end

  def daily_reminder_schedule_key
    "send_daily_reminders_#{@unit.name.parameterize.underscore}"
  end
end
