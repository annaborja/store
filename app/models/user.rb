class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :trackable, :validatable

  has_many :gateway_customers
  has_many :memberships
  has_many :membership_levels, through: :memberships

  def member?
    memberships.active.count.positive?
  end

  def membership_for(level_name)
    memberships
      .active
      .includes(:membership_level)
      .where('membership_levels.name = ?', level_name)
      .references(:membership_level)
      .limit(1)
      .first
  end

  def stripe_customer
    gateway_customers.active.find_by(gateway: GatewayCustomer::GATEWAY.fetch(:stripe))
  end
end
