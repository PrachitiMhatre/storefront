class CouponsController < ApplicationController
  # Show all coupons
  def index
    # For demo, you might want to list coupons from Stripe API or your DB
  end

  # Show form to create coupon
  def new
  end

  # Create coupon + promotion code on Stripe
  def create
    coupon = Stripe::Coupon.create({
      percent_off: params[:percent_off].to_i,
      duration: params[:duration], # "once", "repeating", "forever"
      duration_in_months: params[:duration_in_months].to_i.presence,
      name: params[:name],
      redeem_by: params[:redeem_by].present? ? params[:redeem_by].to_time.to_i : nil,
    })

    promo_code = Stripe::PromotionCode.create({
      coupon: coupon.id,
      code: params[:code],   # unique string like "SUMMER2025"
      active: true,
    })
    
    flash[:notice] = "Created coupon #{coupon.id} and promo code #{promo_code.code}"
    redirect_to coupons_path
  rescue Stripe::StripeError => e
    flash[:alert] = "Stripe error: #{e.message}"
    render :new
  end
end
