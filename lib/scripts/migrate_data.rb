require "active_record"
require "pg"
require "sqlite3"
 
# PostgreSQL database configuration
postgres_config = {
  adapter: "postgresql",
  host: ENV["DATABASE_HOST"],
  username: ENV["DATABASE_USER"],
  password: ENV["DATABASE_PASSWORD"],
  database: "myapp_production"
}
 
# SQLite database configuration
sqlite_config = {
  adapter: "sqlite3",
  database: "storage/production.sqlite3"
}
 
# Establish connections
ActiveRecord::Base.establish_connection(postgres_config)
postgres_connection = ActiveRecord::Base.connection
ActiveRecord::Base.establish_connection(sqlite_config)
sqlite_conn = ActiveRecord::Base.connection
 
# Define the order of tables to migrate
tables_to_migrate = [
  "posts",
  "comments",
  # Add all tables in the correct order (due to foreign key constraints)
]
 
tables_to_migrate.each do |table_name|
  puts "Migrating table: #{table_name}"
 
  # Fetch data from PostgreSQL
  data = postgres_connection.select_all("SELECT * FROM #{table_name}")
 
  # Insert data into SQLite
  data.rows.each do |row|
    attributes = data.columns.zip(row).to_h
    begin
      sqlite_conn.insert_fixture(attributes, table_name)
    rescue => e
      puts "Error inserting into #{table_name}: #{e.message}"
    end
  end
 
  puts "Table #{table_name} migrated successfully."
end
 
puts "Migration completed successfully!"