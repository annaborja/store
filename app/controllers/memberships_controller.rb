class MembershipsController < ApplicationController
  before_action :authenticate_user!

  def create
    Rails.logger.info(params)
    # Amount in cents
    @amount = 500

    # customer = Stripe::Customer.create(
    #   :email => params[:stripeEmail],
    #   :source  => params[:stripeToken]
    # )

    # charge = Stripe::Charge.create(
    #   :customer    => customer.id,
    #   :amount      => @amount,
    #   :description => 'Rails Stripe customer',
    #   :currency    => 'usd'
    # )

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_charge_path
  end

  def new
    @level_param = params[:level].downcase

    @membership_levels = MembershipLevel.all.order(usd_cost: :asc)
  end

  def show
    @user_membership_level_names = current_user.membership_levels.pluck(:name)
    @membership_levels = MembershipLevel.all.order(usd_cost: :asc)
  end
end
