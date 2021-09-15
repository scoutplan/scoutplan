class AddNonNullConstraintToUserType < ActiveRecord::Migration[6.1]
  def change
    User.where(type: nil).update_all(type: 'Adult')

    change_column_null :users, :type, false
  end
end
