# frozen_string_literal: true

Dir[Rails.root.join("lib", "core_ext", "string", "*.rb")].each { |f| require f }
Dir[Rails.root.join("lib", "core_ext", "time", "*.rb")].each { |f| require f }

String.include CoreExtensions::String::TestMethods
String.include CoreExtensions::String::CaseMethods
Time.include CoreExtensions::Time::ToWords
