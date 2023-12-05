User.destroy_all

User.create!(
  email:                 "admin@scoutplan.org",
  password:              "password",
  password_confirmation: "password",
  first_name:            "Bob",
  last_name:             "Dobalina",
  phone:                 "999-555-1212",
  type:                  :adult
)

User.create!(
  email:                 "anne@scoutplan.org",
  password:              "password",
  password_confirmation: "password",
  first_name:            "Anne",
  last_name:             "Avery",
  phone:                 "999-555-1212",
  type:                  :youth
)

User.create!(
  email:                 "brian@scoutplan.org",
  password:              "password",
  password_confirmation: "password",
  first_name:            "Brian",
  last_name:             "Bosworth",
  phone:                 "999-555-1212",
  type:                  :adult
)

User.create!(
  email:                 "debbie@scoutplan.org",
  password:              "password",
  password_confirmation: "password",
  first_name:            "Debbie",
  last_name:             "Doolittle",
  phone:                 "999-555-1212",
  type:                  :youth
)

User.create!(
  email:                 "eric@scoutplan.org",
  password:              "password",
  password_confirmation: "password",
  first_name:            "Eric",
  last_name:             "Einstein",
  phone:                 "999-555-1212",
  type:                  :adult
)

User.create!(
  email:                 "timmy@scoutplan.org",
  password:              "password",
  password_confirmation: "password",
  first_name:            "Timmy",
  last_name:             "Dobalina",
  phone:                 "999-555-1212",
  phone:                 "555-1212",
  type:                  :youth
)

User.create!(
  email:                 "taylor@scoutplan.org",
  password:              "password",
  password_confirmation: "password",
  first_name:            "Taylor",
  last_name:             "Dobalina",
  phone:                 "555-1212",
  type:                  :youth
)

puts "#{User.count} users now exist"
