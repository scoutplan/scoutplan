# frozen_string_literal: true

# class for managing a Unit's Tasks
# called from UnitsController#update
# to add a new Task type
# 1. add a new key to TASK_KEYS, below
# 2. add these values to en.yml:
# 3. add a new translations to config/locales/en.yml under settings:
#   a. descriptions
#   b. icons
#   c. icon_colors
#   d. titles
#   e. labels

class UnitTaskService
  TASK_KEYS = { communication: {
    rsvp_nag:               "RsvpNagTask",
    rsvp_last_call:         "RsvpLastCallTask",
    event_organizer_digest: "EventOrganizerDigestTask"
  } }.freeze

  def initialize(unit)
    @unit = unit
  end

  # create or destroy tasks based on unit settings
  def setup_tasks_from_settings
    TASK_KEYS.each do |category, cat_values|
      cat_values.each do |task_key, task_class|
        setup_task(category, task_key, task_class)
      end
    end
    setup_schedules
    SendWeeklyDigestJob.schedule_next_job(@unit)
  end

  # given a setting category, key, and task class, create or destroy the task
  def setup_task(category, task_key, task_class)
    value = @unit.settings(category).value[task_key.to_s]
    @unit.tasks.find_or_create_by(key: task_key, type: task_class) if value == "true"
    @unit.tasks.find_by(key: task_key)&.destroy if value == "false"
  end

  # create or destroy schedules based on unit settings
  def setup_schedules
    @unit.tasks.each(&:setup_schedule)
  end
end
