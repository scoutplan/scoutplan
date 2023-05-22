class VersionJsonMigration < ActiveRecord::Migration[7.0]
  def change
    add_column :versions, :new_object, :jsonb

    PaperTrail::Version.where.not(object: nil).find_each do |version|
      version.update_columns(new_object: YAML.unsafe_load(version.object))
    end

    remove_column :versions, :object
    rename_column :versions, :new_object, :object
  end
end
