class CreateMagicLinks < ActiveRecord::Migration[6.1]
  def change
    create_table :magic_links do |t|
      t.string :token
      t.integer :unit_membership_id
      t.datetime :expires_at

      t.timestamps
    end
  end
end
