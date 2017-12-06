class AddSubscriptionInfoToMembershipsAndMembershipLevels < ActiveRecord::Migration[5.1]
  def change
    add_column :membership_levels, :subscription_plan_id, :string
    add_column :memberships, :gateway, :string
    add_column :memberships, :subscription_id, :string

    change_column :membership_levels, :subscription_plan_id, :string, null: false
    change_column :memberships, :gateway, :string, null: false
    change_column :memberships, :subscription_id, :string, null: false

    add_index :membership_levels, :subscription_plan_id, unique: true
    add_index :memberships, %i[gateway subscription_id], unique: true
  end
end
