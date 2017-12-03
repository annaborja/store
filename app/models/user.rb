class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :recoverable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :rememberable, :trackable, :validatable

  has_many :memberships
  has_many :membership_levels, through: :memberships
  has_many :gateway_customers

  def membership_level_names
    membership_levels.pluck(:name)
  end

  def stripe_customer
    gateway_customers.active.find_by(gateway: GatewayCustomer::GATEWAY.fetch(:stripe))
  end
end
