class AddSubscriptionInfoToMembershipLevels < ActiveRecord::Migration[5.1]
  def change
    add_column :membership_levels, :guest_subscription_plan_id, :string
    add_column :membership_levels, :num_trial_days, :integer

    change_column :membership_levels, :guest_subscription_plan_id, :string, null: false
    change_column :membership_levels, :num_trial_days, :integer, null: false
  end
end
