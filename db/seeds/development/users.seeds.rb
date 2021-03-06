# frozen_string_literal: true

User.destroy_all

bob = User.create!(
  email: 'admin@scoutplan.org',
  password: 'password',
  password_confirmation: 'password',
  first_name: 'Bob',
  last_name: 'Dobalina',
  phone: '555-1212',
  type: :adult
)

anne = User.create!(
  email: 'anne@scoutplan.org',
  password: 'password',
  password_confirmation: 'password',
  first_name: 'Anne',
  last_name: 'Avery',
  phone: '555-1212',
  type: :youth
)

brian = User.create!(
  email: 'brian@scoutplan.org',
  password: 'password',
  password_confirmation: 'password',
  first_name: 'Brian',
  last_name: 'Bosworth',
  phone: '555-1212',
  type: :adult
)

debbie = User.create!(
  email: 'debbie@scoutplan.org',
  password: 'password',
  password_confirmation: 'password',
  first_name: 'Debbie',
  last_name: 'Doolittle',
  phone: '555-1212',
  type: :youth
)

eric = User.create!(
  email: 'eric@scoutplan.org',
  password: 'password',
  password_confirmation: 'password',
  first_name: 'Eric',
  last_name: 'Einstein',
  phone: '555-1212',
  type: :adult
)

timmy = User.create!(
  email: 'timmy@scoutplan.org',
  password: 'password',
  password_confirmation: 'password',
  first_name: 'Timmy',
  last_name: 'Dobalina',
  phone: '555-1212',
  type: :youth
)

bob.child_relationships.create!(child: timmy)
bob.child_relationships.create!(child: anne)
bob.child_relationships.create!(child: debbie)

puts "#{User.count} users now exist"
