class AddPathToMagicLinks < ActiveRecord::Migration[7.0]
  def change
    MagicLink.destroy_all
    add_column :magic_links, :path, :string, null: false
  end
end
