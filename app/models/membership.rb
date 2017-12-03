class Membership < ApplicationRecord
  belongs_to :membership_level
  belongs_to :user
end
