FactoryBot.define do
  sequence :membership_level_name { |n| "membership_level_#{n}" }
  sequence :guest_subscription_plan_id { |n| "guest-subscription-plan-#{n}" }
  sequence :subscription_plan_id { |n| "subscription-plan-#{n}" }

  factory :membership_level do
    name { generate :membership_level_name }
    subscription_plan_id { generate :subscription_plan_id }
    guest_subscription_plan_id { generate :guest_subscription_plan_id }
    usd_cost 1999
    num_free_guests 0
    additional_guest_usd_cost 1999
    num_trial_days 15
  end
end
