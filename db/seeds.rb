# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if User.count.zero?
  User.create!(email: 'foo@baz.com',
               password: 'password',
               password_confirmation: 'password')
end

[{
  name: 'basic',
  subscription_plan_id: 'basic-monthly-usd',
  guest_subscription_plan_id: 'guest-monthly-usd',
  usd_cost: 1999,
  num_free_guests: 0,
  additional_guest_usd_cost: 1999,
  num_trial_days: 15
}, {
  name: 'classic',
  subscription_plan_id: 'classic-monthly-usd',
  guest_subscription_plan_id: 'guest-monthly-usd',
  usd_cost: 9999,
  num_free_guests: 5,
  additional_guest_usd_cost: 1999,
  num_trial_days: 15
}, {
  name: 'modern',
  subscription_plan_id: 'modern-monthly-usd',
  guest_subscription_plan_id: 'guest-monthly-usd',
  usd_cost: 19_999,
  num_free_guests: 5,
  additional_guest_usd_cost: 1999,
  num_trial_days: 15
}]
  .select { |attrs| MembershipLevel.find_by(name: attrs[:name]).nil? }
  .each { |attrs| MembershipLevel.create!(attrs) }
