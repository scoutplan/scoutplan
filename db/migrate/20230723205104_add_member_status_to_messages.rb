class AddMemberStatusToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :member_status, :string, default: "active"
  end
end
