class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def new
    @plans = Plan.all

    customer = if current_user.stripe_customer_id
                 Stripe::Customer.retrieve(current_user.stripe_customer_id)
               else
                 c = Stripe::Customer.create(email: current_user.email)
                 current_user.update!(stripe_customer_id: c.id)
                 c
               end

    @setup_intent = Stripe::SetupIntent.create(customer: customer.id)
  end

  def create
    plan = Plan.find(params[:plan_id])

    subscription = Stripe::Subscription.create({
      customer: current_user.stripe_customer_id,
      items: [{ price: plan.stripe_price_id }],
      default_payment_method: params[:payment_method]
    })

    current_user.subscriptions.create!(
      plan: plan,
      stripe_subscription_id: subscription.id,
      status: subscription.status
    )

    redirect_to root_path, notice: "Subscription started successfully!"
  rescue Stripe::StripeError => e
    redirect_to new_subscription_path, alert: e.message
  end
end
