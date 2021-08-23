after 'development:units', 'development:users' do
  unit = Unit.first
  User.all.each do |user|
    role = user.email == 'admin@scoutplan.org' ? 'admin' : 'member'
    user.unit_memberships.create(unit: unit, role: role)
  end
end
