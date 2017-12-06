FactoryBot.define do
  sequence :email { |n| "foo#{n}@example.com" }

  factory :user do
    email { generate :email }
    password 'abc123'
  end
end
