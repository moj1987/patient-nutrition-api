class AddDetailsToPatients < ActiveRecord::Migration[8.1]
  def change
    add_column :patients, :age, :integer
    add_column :patients, :room_number, :string
    add_column :patients, :dietary_restrictions, :jsonb
    add_column :patients, :admition_date, :date
    add_column :patients, :status, :integer
  end
end
