class CreateMembershipLevels < ActiveRecord::Migration[5.1]
  def change
    create_table :membership_levels do |t|
      t.string :name, null: false
      t.integer :usd_cost, null: false
      t.integer :free_guests, default: 0, null: false
      t.integer :additional_guest_usd_cost, default: 1999, null: false

      t.timestamps
    end

    add_index :membership_levels, :name, unique: true

    add_column :users, :membership_level_id, :integer
  end
end
