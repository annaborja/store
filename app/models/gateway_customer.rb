class GatewayCustomer < ApplicationRecord
  GATEWAY = {
    stripe: 'stripe'.freeze,
  }.freeze

  scope :active, -> { where(deleted_at: nil) }

  validates :customer_id, presence: true
  validates :gateway, inclusion: GATEWAY.values
  validates :user_id, numericality: { only_integer: true }
end
