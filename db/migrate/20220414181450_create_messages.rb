class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.integer :unit_membership_id
      t.datetime :send_at
      t.string :title
      t.text :body
      t.integer :status

      t.timestamps
    end
  end
end
