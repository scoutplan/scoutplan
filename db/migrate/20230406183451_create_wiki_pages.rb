class CreateWikiPages < ActiveRecord::Migration[7.0]
  def change
    create_table :wiki_pages do |t|
      t.integer :unit_id
      t.string :title, null: false
      t.string :visibility, default: "draft", null: false
      t.text :body

      t.timestamps
    end
  end
end
