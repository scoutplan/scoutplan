class CreateExternalIntegrations < ActiveRecord::Migration[7.1]
  def change
    create_table :external_integrations do |t|
      t.string :type
      t.string :identifier
      t.integer :unit_id
      t.string :token
      t.jsonb :data

      t.timestamps
    end
  end
end
