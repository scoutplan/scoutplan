class AddTtlToMagicLinks < ActiveRecord::Migration[7.0]
  def change
    add_column :magic_links, :time_to_live, :integer, default: 432_000

    MagicLink.where(expires_at: nil).update_all(time_to_live: nil)
  end
end
