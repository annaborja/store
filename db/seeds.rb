# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

MembershipLevel.create!([{
  name: 'basic',
  usd_cost: 1999,
  free_guests: 0,
  additional_guest_usd_cost: 1999,
}, {
  name: 'modern',
  usd_cost: 9999,
  free_guests: 5,
  additional_guest_usd_cost: 1999,
}, {
  name: 'classic',
  usd_cost: 19999,
  free_guests: 5,
  additional_guest_usd_cost: 1999,
}])
