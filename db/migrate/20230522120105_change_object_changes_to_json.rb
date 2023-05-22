class ChangeObjectChangesToJson < ActiveRecord::Migration[7.0]  
  def change
    add_column :versions, :new_object_changes, :jsonb
    PaperTrail::Version.where.not(object_changes: nil).find_each do |version|
      version.update_columns(new_object_changes: YAML.unsafe_load(version.object_changes))
    end

    remove_column :versions, :object_changes
    rename_column :versions, :new_object_changes, :object_changes
  end
end
