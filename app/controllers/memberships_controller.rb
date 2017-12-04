class MembershipsController < ApplicationController
  before_action :authenticate_user!

  def complete_successful_create(membership_level)
    flash[:notice] = I18n.t('membership.purchase_form.success',
      level: I18n.t("membership.level.#{membership_level.name}.name")
    )

    redirect_to memberships_path
  end

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

    flash[:errors] << I18n.t('membership.purchase_form.error.invalid_level') if
      membership_level.nil?

    return redirect_to(new_membership_path) if flash[:errors].length > 0

    user_id = current_user.id

    flash[:errors] << I18n.t('membership.purchase_form.error.already_member',
      level: I18n.t("membership.level.#{membership_level.name}.name")
    ) if Membership.active.where(
      membership_level_id: membership_level.id,
      user_id: user_id
    ).count > 0

    return redirect_to(new_membership_path) if flash[:errors].length > 0

    customer_id = if current_user.stripe_customer
      current_user.stripe_customer.customer_id
    else
      Stripe::Customer.create(
        email: params[:stripeEmail],
        source: params[:stripeToken]
      ).id
    end

    gateway = GatewayCustomer::GATEWAY.fetch(:stripe)
    membership = Membership.new(
      gateway: gateway,
      membership_level_id: membership_level.id,
      num_guests: num_guests,
      user_id: user_id
    )
    subscription = Stripe::Subscription.create(
      customer: customer_id,
      items: [{
        plan: membership_level.subscription_plan_id,
      }, {
        plan: membership_level.guest_subscription_plan_id,
        quantity: membership.num_charged_guests,
      }],
      trial_period_days: membership_level.num_trial_days
    )

    membership.subscription_id = subscription.id
    membership.save!

    # Only save the Stripe customer ID if the Stripe subscription was successfully created.
    GatewayCustomer.create!(
      customer_id: customer_id,
      gateway: gateway,
      user_id: user_id
    )

    complete_successful_create(membership_level)
  rescue ActiveRecord::ActiveRecordError => e
    # If one of our db calls errored out,
    # that means that our Stripe calls have already succeeded,
    # so log the db error and show the user a success result.
    Rails.logger.error(e)

    complete_successful_create(membership_level)
  rescue Stripe::CardError => e
    flash[:errors] = [e.message]

    redirect_to new_membership_path
  end

  def new
    @membership_levels = MembershipLevel
      .where.not(name: current_user.membership_levels.pluck(:name))
      .order(usd_cost: :asc)

    return redirect_to(membership_path) if @membership_levels.length == 0

    level = params[:level].try(:downcase)

    @gateway_customers = current_user.gateway_customers
    @prepopulated_level = @membership_levels.find_by(name: level) if level.present?
  end

  def show
    @membership_levels = MembershipLevel.all.order(usd_cost: :asc)
  end
end
