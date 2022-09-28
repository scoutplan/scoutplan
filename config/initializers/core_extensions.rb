# frozen_string_literal: true

Dir[Rails.root.join("lib", "core_ext", "string", "*.rb")].each { |f| require f }
Dir[Rails.root.join("lib", "core_ext", "time", "*.rb")].each { |f| require f }
Dir[Rails.root.join("lib", "core_ext", "date_time_attrs", "*.rb")].each { |f| require f }

String.include CoreExtensions::String::TestMethods
Time.include CoreExtensions::Time::ToWords
