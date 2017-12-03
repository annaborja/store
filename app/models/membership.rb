class Membership < ApplicationRecord
  belongs_to :membership_level
  belongs_to :user

  scope :active, -> { where(canceled_at: nil) }

  validates :membership_level_id, numericality: { only_integer: true }
  validates :num_guests, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :user_id, numericality: { only_integer: true }

  def usd_cost
    membership_level.usd_cost +
      [num_guests - membership_level.num_free_guests, 0].max *
      membership_level.additional_guest_usd_cost
  end
end
