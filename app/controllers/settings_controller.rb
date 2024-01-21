# frozen_string_literal: true

# this has been superceded by the UnitsController + UnitTaskService

class SettingsController < UnitContextController
  TASK_KEY_RSVP_NAG = "rsvp_nag"
  TASK_DAY_RSVP_NAG = 2 # Tuesday
  TASK_HOUR_RSVP_NAG = 10 # 10 AM local

  before_action :find_unit

  # GET /units/:unit_id/settings
  def edit
    @page_title = [@unit.name, "Settings"]
    authorize @unit, policy_class: UnitSettingsPolicy
  end

  def index
    authorize @unit, :edit?
  end

  # POST /unit/:unit_id/settings
  def update
    @unit.update(unit_params) if params[:unit].present?
    @unit.settings(:utilities).fire_scheduled_tasks = true if params.dig(:settings, :utilities, :fire_scheduled_tasks)
    @unit.settings(:locale).meeting_location = params.dig(:settings, :locale, :meeting_location)
    @unit.settings(:locale).meeting_address = params.dig(:settings, :locale, :meeting_address)
    @unit.settings(:communication).rsvp_nag = params.dig(:settings, :communication, :rsvp_nag)

    set_schedule

    @unit.save!
    redirect_to unit_settings_path(@unit)
  end

  def pundit_user
    @current_member
  end

  def difference_in_days(from, to)
    (to.to_date - from.to_date).to_i
  end

  private

  # handle scheduled task serialization
  def set_schedule
    ap "set_schedule"
    Time.zone = @unit.settings(:locale).time_zone
    set_digest_schedule
    set_rsvp_nag_schedule
  end

  def set_rsvp_nag_schedule
    @unit.settings(:communication).rsvp_nag = params.dig(:settings, :communication, :rsvp_nag)
    @unit.settings(:communication).rsvp_nag_day_of_week = params.dig(:settings, :communication, :rsvp_nag_day_of_week)
    @unit.settings(:communication).rsvp_nag_hour_of_day = params.dig(:settings, :communication, :rsvp_nag_hour_of_day)
    @unit.settings(:communication).rsvp_nag_config_timestamp = DateTime.current

    RsvpNagJob.schedule_next_job(@unit)
  end

  def set_digest_schedule
    @unit.settings(:communication).digest = params.dig(:settings, :communication, :digest)
    @unit.settings(:communication).digest_day_of_week = params.dig(:settings, :communication, :digest_day_of_week)
    @unit.settings(:communication).digest_hour_of_day = params.dig(:settings, :communication, :digest_hour_of_day)
    @unit.settings(:communication).digest_config_timestamp = DateTime.current

    SendWeeklyDigestJob.schedule_next_job(@unit)
  end

  def find_unit
    @current_unit = @unit = Unit.find(params[:unit_id])
    @current_member = @unit.membership_for(current_user)
    Time.zone = @unit.settings(:locale).time_zone
  end

  def unit_params
    params.require(:unit).permit(
      :name,
      :location,
      :logo,
      :slug,
      :allow_youth_rsvps,
      settings: [
        [communication: [:rsvp_nag, { digest_schedule: [:day_of_week, :hour_of_day, :every_hour] }]],
        :utilities
      ]
    )
  end
end

# IceCube::Schedule.new.add_recurrence_rule(IceCube::Rule.weekly.day(0).hour_of_day(7).minute_of_hour(0))
