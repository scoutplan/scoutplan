class CreateNewsItems < ActiveRecord::Migration[6.1]
  def change
    create_table :news_items do |t|
      t.integer :unit_id
      t.string :title
      t.text :body
      t.string :status, null: false, default: 'draft'
      t.integer :position

      t.timestamps
    end
  end
end
