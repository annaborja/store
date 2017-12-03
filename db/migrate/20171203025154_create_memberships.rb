class CreateMemberships < ActiveRecord::Migration[5.1]
  def change
    create_table :memberships do |t|
      t.integer :user_id, null: false
      t.integer :membership_level_id, null: false
      t.integer :num_guests, null: false

      t.datetime :canceled_at
      t.timestamps
    end

    add_index :memberships, [:user_id, :membership_level_id, :canceled_at], name: 'index_memberships_on_ids_and_canceled_at'

    remove_column :users, :membership_level_id
    rename_column :membership_levels, :free_guests, :num_free_guests
  end
end
