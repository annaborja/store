FactoryBot.define do
  factory :membership_level do
    name 'basic'
    subscription_plan_id 'basic-monthly-usd'
    guest_subscription_plan_id 'guest-monthly-usd'
    usd_cost 1999
    num_free_guests 0
    additional_guest_usd_cost 1999
    num_trial_days 15
  end
end
