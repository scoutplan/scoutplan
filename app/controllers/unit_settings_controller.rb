# frozen_string_literal: true

class UnitSettingsController < UnitContextController
  before_action :find_unit

  def edit
    @page_title = [@unit.name, 'Settings']
    authorize @unit, policy_class: UnitSettingsPolicy
    schedule_hash = @unit.settings(:communication).digest_schedule
    @schedule = IceCube::Schedule.from_hash(schedule_hash) if schedule_hash
  end

  def update
    @unit.update(unit_params) if params[:unit].present?
    @unit.settings(:utilities).fire_scheduled_tasks = true if params.dig(:settings, :utilities, :fire_scheduled_tasks)

    set_schedule
    @unit.settings(:communication).digest_schedule = @schedule

    @unit.save!
    redirect_to edit_unit_settings_path(@unit)
  end

  # rubocop:disable Style/GuardClause
  def set_schedule
    day_of_week = params.dig(:settings, :communication, :digest_schedule, :day_of_week).to_i
    hour_of_day = params.dig(:settings, :communication, :digest_schedule, :hour_of_day).to_i
    @schedule = IceCube::Schedule.new
    @schedule.add_recurrence_rule IceCube::Rule.weekly.day(day_of_week).hour_of_day(hour_of_day).minute_of_hour(0)
    if params.dig(:settings, :communication, :digest_schedule, :every_hour) == "yes"
      @schedule.add_recurrence_rule IceCube::Rule.minutely(60)
    end
  end
  # rubocop:enable Style/GuardClause

  def pundit_user
    @current_member
  end

  private

  def find_unit
    @current_unit = @unit = Unit.find(params[:id])
    @current_member = @unit.membership_for(current_user)
  end

  def unit_params
    params.require(:unit).permit(
      :name,
      :location,
      :logo,
      settings: [
        [communication: [digest_schedule: [:day_of_week, :hour_of_day, :every_hour]]],
        :utilities
      ]
    )
  end
end

# IceCube::Schedule.new.add_recurrence_rule(IceCube::Rule.weekly.day(0).hour_of_day(7).minute_of_hour(0))
