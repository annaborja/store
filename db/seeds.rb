# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create!({
  email: 'foo@baz.com',
  password: 'password',
  password_confirmation: 'password',
}) if User.count == 0

user_id = User.first.id

[{
  name: 'basic',
  usd_cost: 1999,
  num_free_guests: 0,
  additional_guest_usd_cost: 1999,
}, {
  name: 'modern',
  usd_cost: 9999,
  num_free_guests: 5,
  additional_guest_usd_cost: 1999,
}, {
  name: 'classic',
  usd_cost: 19999,
  num_free_guests: 5,
  additional_guest_usd_cost: 1999,
}].map do |attrs|
  membership_level = MembershipLevel.find_by(name: attrs[:name])

  next membership_level unless membership_level.nil?

  MembershipLevel.create!(attrs)
end.each do |membership_level|
  next if Membership.active.where(membership_level_id: membership_level.id, user_id: user_id).count > 0

  Membership.create!({
    membership_level_id: membership_level.id,
    user_id: user_id,
    num_guests: membership_level.num_free_guests + Random.new.rand(-3..3),
  })
end
