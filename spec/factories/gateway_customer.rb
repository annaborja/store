FactoryBot.define do
  sequence :customer_id { |n| "customer_#{n}" }

  factory :gateway_customer do
    customer_id { generate :customer_id }
    gateway GatewayCustomer::GATEWAY.fetch(:stripe)
    user { create :user }
  end
end
