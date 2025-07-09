class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      render json: { error: 'Invalid payload' }, status: 400 and return
    rescue Stripe::SignatureVerificationError => e
      render json: { error: 'Invalid signature' }, status: 400 and return
    end

    case event.type
    when 'checkout.session.completed'
      session = event.data.object

      # ✅ Payment successful
      handle_successful_checkout(session)
    when 'checkout.session.expired'
      # ⚠️ Optional: Session expired
    else
      Rails.logger.info("Unhandled event type: #{event.type}")
    end

    render json: { message: 'Event received' }
  end

  private

  def handle_successful_checkout(session)
    # Lookup product if you stored metadata (recommended)
    # For example: session.metadata["product_id"]
    product_name = session.line_items&.first&.description || session.metadata&.dig("product_name")

    # You can track the user/payment here
    Rails.logger.info "Payment succeeded for session: #{session.id}"
    Rails.logger.info "Customer email: #{session.customer_details.email}"

    # You could mark the product as purchased, create an order, etc.
  end
end
