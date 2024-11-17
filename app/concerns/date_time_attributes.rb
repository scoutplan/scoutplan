# frozen_string_literal: true

# adds a `date_time_attrs_for` class method
# so that we can pass individual date and time strings
# usage: date_time_fields :start_time => starts_at_date, starts_at_time methods
module DateTimeAttributes
  def date_time_attrs_for(*attr_names)
    attr_names.each do |attr_name|
      date_attr_name = "#{attr_name}_date"
      time_attr_name = "#{attr_name}_time"

      class_eval <<-CODE, __FILE__, __LINE__ + 1
        # # original attribute setter
        # def #{attr_name}=(val)  # def starts_at=(str)
        #   return unless val.is_a?(Date) || val.is_a?(DateTime)
        #   self.send(:#{attr_name}=, val)
        # end

        # date getter
        def #{date_attr_name}     # def starts_at_date
          #{attr_name}&.to_date   #   starts_at&.to_date
        end                       # end

        # time getter
        def #{time_attr_name}     # def starts_at_time
          #{attr_name}&.to_time   #  starts_at&.to_time
        end                       # end

        # date setter
        def #{date_attr_name}=(str)                                                                                   # def starts_at_date=(str)
          t = Time.parse(str)                                                                                     #   t = DateTime.parse(str)
          self.send(:#{attr_name}=, (#{attr_name} || DateTime.now).change(year: t.year, month: t.month, day: t.day))  #   self.send(:starts_at=, (starts_at || DateTime.now).change(year: t.year, month: t.month, day: t.day))
        end                                                                                                           # end

        # time setter
        def #{time_attr_name}=(str)                                                                                   # def starts_at_time=(str)
          t = Time.parse(str)                                                                                     #   t = DateTime.parse(str)
          self.send(:#{attr_name}=, (#{attr_name} || DateTime.now).change(hour: t.hour, min: t.min, sec: t.sec))      #   self.send(:starts_at=, (starts_at || DateTime.now).change(year: t.year, month: t.month, day: t.day))
        end                                                                                                           # end
      CODE
    end
  end
end
