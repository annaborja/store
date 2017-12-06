class GatewayCustomer < ApplicationRecord
  GATEWAY = {
    stripe: 'stripe'.freeze,
  }.freeze

  belongs_to :user

  scope :active, -> { where(deleted_at: nil) }

  validates :customer_id, length: { maximum: 255 }, presence: true
  validates :gateway, inclusion: GATEWAY.values
  validates :user_id, numericality: { only_integer: true }
end
