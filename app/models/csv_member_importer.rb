class CsvMemberImporter
  def self.perform_import(file, unit)
    new_memberships = []
    existing_memberships = []

    data = SmarterCSV.process(file.tempfile)
    data.each do |row|
      email           = row[:email]&.downcase || User.generate_anonymous_email
      existing_user   = User.find_by(email: email)
      existing_member = unit.membership_for(existing_user)

      if existing_user && existing_member
        existing_memberships << existing_member
      elsif existing_user
        membership = unit.memberships.create!(user: existing_user, status: :active, role: :member)
        new_memberships << membership
      else
        generated_password = Devise.friendly_token.first(8)
        user = User.new(
          first_name: row[:first_name],
          last_name: row[:last_name],
          phone: row[:phone],
          password: generated_password,
          password_confirmation: generated_password,
          email: email,
          type: :adult
        )
        user.save!

        membership = unit.memberships.create!(user: user, status: :active, role: :member)
        new_memberships << membership
      end
    end
    { new_memberships: new_memberships, existing_memberships: existing_memberships }
  end
end
