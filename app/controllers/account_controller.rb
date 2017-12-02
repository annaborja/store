class AccountController < ApplicationController
  before_action :authenticate_user!

  def membership
    @has_membership = !!current_user.membership_level
    @membership_levels = MembershipLevel.all.order(usd_cost: :asc)
  end
end
