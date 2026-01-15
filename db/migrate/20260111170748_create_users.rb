class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true }

      t.timestamps
    end

    # Create default admin user
    User.create!(email: 'm29038015@gmail.com')
  end
end
