# frozen_string_literal: true

# adds a `date_time_attrs_for` class method
# so that we can pass individual date and time strings
# usage: date_time_fields :start_time => starts_at_date, starts_at_time methods
module DateTimeAttributes
  # rubocop:disable Metrics/MethodLength
  def date_time_attrs_for(*attr_names)
    attr_names.each do |attr_name|
      date_attr_name = "#{attr_name}_date"
      time_attr_name = "#{attr_name}_time"

      class_eval <<-CODE, __FILE__, __LINE__ + 1
        # date getter
        def #{date_attr_name}
          #{attr_name}&.to_date
        end

        # time getter
        def #{time_attr_name}
          #{attr_name}&.to_time
        end

        # date setter
        def #{date_attr_name}=(str)
          t = DateTime.parse(str)
          self.send(:#{attr_name}=, (#{attr_name} || DateTime.now).change(year: t.year, month: t.month, day: t.day))
        end

        # time setter
        def #{time_attr_name}=(str)
          t = DateTime.parse(str)
          self.send(:#{attr_name}=, (#{attr_name} || DateTime.now).change(hour: t.hour, min: t.min, sec: t.sec))
        end
      CODE
    end
  end
  # rubocop:enable Metrics/MethodLength
end
