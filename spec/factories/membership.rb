FactoryBot.define do
  sequence :subscription_id { |n| "subscription_#{n}" }

  factory :membership do
    gateway GatewayCustomer::GATEWAY.fetch(:stripe)
    membership_level { create :membership_level }
    num_guests 0
    subscription_id { generate :subscription_id }
    user { create :user }
  end
end
