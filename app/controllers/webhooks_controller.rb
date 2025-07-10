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

      # Payment successful
      handle_successful_checkout(session)
    
    when 'payment_intent.created'
      payment_intent = event.data.object
      handle_payment_intent_created(payment_intent)

    when 'payment_intent.succeeded'
      payment_intent = event.data.object
      handle_payment_intent_succeeded(payment_intent)

    when 'payment_intent.payment_failed'
      payment_intent = event.data.object
      handle_payment_intent_failed(payment_intent)

    when 'checkout.session.expired'
      # Optional: Session expired
    else
      Rails.logger.info("Unhandled event type: #{event.type}")
    end

    render json: { message: 'Event received' }
  end

  private

  def handle_successful_checkout(session)
    # Lookup product if you stored metadata (recommended)
    # For example: session.metadata["product_id"]
    product_name = session.line_items&.first&.description || session.metadata&.[]("product_name")
    # You can track the user/payment here
    Rails.logger.info "Payment succeeded for session: #{session.id}"
    Rails.logger.info "Customer email: #{session.customer_details.email}"

    # You could mark the product as purchased, create an order, etc.
  end

  def handle_payment_intent_succeeded(payment_intent)
    customer_id = payment_intent.customer
    amount = payment_intent.amount_received
    metadata = payment_intent.metadata

    Rails.logger.info "PaymentIntent succeeded: #{payment_intent.id}"
    Rails.logger.info "Amount received #{amount}"
    Rails.logger.info "Metadata: #{metadata.inspect}"
  
    user = User.find_by(id: metadata["user_id"])
    product = Product.find_by(id: metadata["product_id"])

    return unless user && product
    
    # Create order
    Order.create!(
      user: user,
      product: product,
      total_amount: amount,
      payment_status: "succeeded",
      stripe_payment_intent_id: payment_intent.id
    )
    Rails.logger.info "Order created for User##{user.id} for Product##{product.id}"
    # Example: Find user or order by metadata
    # user = User.find_by(stripe_customer_id: customer_id)
    # Order.find_by(id: metadata["order_id"])&.mark_as_paid!
  end

  def handle_payment_intent_created(payment_intent)
    Rails.logger.info "PaymentIntent created: #{payment_intent.id}"
    Rails.logger.info "Amount: #{payment_intent.amount}"
    Rails.logger.info "Customer ID: #{payment_intent.customer}"
    Rails.logger.info "Metadata: #{payment_intent.metadata.inspect}"
  end

  def handle_payment_intent_failed(payment_intent)
    error_message = payment_intent.last_payment_error&.message

    Rails.logger.warn "PaymentIntent failed: #{payment_intent.id}"
    Rails.logger.warn "Error message: #{error_message}"
  end
end
