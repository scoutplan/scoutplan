# adds a `date_time_fields_for` macro to classes
# so that we can pass individual date and time strings
# usage: date_time_fields :start_time
require "date"

module DateTimeFields
  def date_time_fields_for(*attr_names)
    attr_names.each do |attr_name|
      date_attr_name = "#{attr_name}_date"
      time_attr_name = "#{attr_name}_time"

      class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{date_attr_name}
          @#{attr_name}&.to_time
        end

        def #{time_attr_name}
          @#{attr_name}&.to_date
        end

        def #{date_attr_name}=(date_str)
          t = DateTime.parse(date_str)
          @#{attr_name} ||= DateTime.new
          @#{attr_name} = ::DateTime.civil(t.year, t.month, t.day, @#{attr_name}.hour, @#{attr_name}.min, @#{attr_name}.sec)
          instance_variable_get("@#{attr_name}")
        end

        def #{time_attr_name}=(time_str)
          t = DateTime.parse(time_str)
          @#{attr_name} ||= DateTime.new
          @#{attr_name} = ::DateTime.civil(@#{attr_name}.year, @#{attr_name}.month, @#{attr_name}.day, t.hour, t.min, t.sec)
          instance_variable_get("@#{attr_name}")
        end
      CODE
    end
  end
end
