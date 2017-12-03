class MembershipsController < ApplicationController
  before_action :authenticate_user!

  def create
    level = params[:level]
    num_guests = params[:num_guests].to_i

    flash[:errors] = []
    flash[:errors] << I18n.t('membership.purchase_form.error.blank_level') if level.blank?
    flash[:errors] << I18n.t('membership.purchase_form.error.invalid_num_guests') if
      params[:num_guests].blank? ||
      num_guests < 0

    return redirect_to(new_membership_path) if flash[:errors].length > 0

    membership_level = MembershipLevel.find_by(name: level)

    flash[:errors] << I18n.t('membership.purchase_form.error.invalid_level') if membership_level.nil?

    return redirect_to(new_membership_path) if flash[:errors].length > 0

    user_id = current_user.id

    flash[:errors] << I18n.t('membership.purchase_form.error.already_member',
      level: I18n.t("membership.level.#{membership_level.name}.name"),
    ) if Membership.active.where(
      membership_level_id: membership_level.id,
      user_id: user_id
    ).count > 0

    return redirect_to(new_membership_path) if flash[:errors].length > 0

    gateway = GatewayCustomer::GATEWAY.fetch(:stripe)
    membership = Membership.new(
      gateway: gateway,
      membership_level_id: membership_level.id,
      num_guests: num_guests,
      user_id: user_id,
    )

    customer_id = if current_user.stripe_customer
      current_user.stripe_customer.customer_id
    else
      customer = Stripe::Customer.create(
        email: params[:stripeEmail],
        source: params[:stripeToken],
      )

      GatewayCustomer.create!(
        customer_id: customer.id,
        gateway: gateway,
        user_id: user_id,
      ).customer_id
    end

    subscription = Stripe::Subscription.create(
      customer: customer_id,
      items: [{
        plan: membership_level.subscription_plan_id,
      }],
    )

    membership.subscription_id = subscription.id
    membership.save!
  rescue Stripe::CardError => e
    flash[:errors] = [e.message]

    redirect_to new_membership_path
  end

  def new
    @membership_levels = MembershipLevel
      .where.not(name: current_user.membership_level_names)
      .order(usd_cost: :asc)

    return redirect_to(membership_path) if @membership_levels.length == 0

    @level = params[:level].try(:downcase)
  end

  def show
    @membership_levels = MembershipLevel.all.order(usd_cost: :asc)
    @user_membership_level_names = current_user.membership_level_names
  end
end
