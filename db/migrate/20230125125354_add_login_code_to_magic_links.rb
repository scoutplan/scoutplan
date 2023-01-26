class AddLoginCodeToMagicLinks < ActiveRecord::Migration[7.0]
  def change
    add_column :magic_links, :login_code, :string
  end
end
