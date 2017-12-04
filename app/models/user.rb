class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :recoverable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :rememberable, :trackable, :validatable

  has_many :memberships
  has_many :membership_levels, through: :memberships
  has_many :gateway_customers

  def member?
    memberships.active.count > 0
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
