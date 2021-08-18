user = User.new(
  email:                  'admin@scoutplan.org',
  password:               'password',
  password_confirmation:  'password',
)

user.save!


puts "#{User.count} users now exist"
