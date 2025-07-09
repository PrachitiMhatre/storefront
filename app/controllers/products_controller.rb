class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products or /products.json
  def index
    @products = Product.all
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

#payment using Stripe checkout session
# def checkout
#   product = Product.find(params[:id])

#   session = Stripe::Checkout::Session.create(
#     mode: "subscription",
#     customer: current_user.stripe_customer_id, # optional but recommended
#     metadata: {
#       product_id: product.id,
#       user_id: current_user.id
#     },
#     allow_promotion_codes: true,
#     line_items: [{
#       price: product.stripe_price_id,
#       quantity: 1
#     }],
#     customer_update: {
#       name: 'auto',
#       address: 'auto'
#     },
#     shipping_address_collection: {
#     allowed_countries: ['US', 'CA', 'GB'] # limit to specific countries
#     },
#     # discounts: [{
#     #   promotion_code: 'promo_1Riu7PGhhMWnUmbBwml17hMd'
#     # }],
#     success_url: product_url(product, paid: true),
#     cancel_url: product_url(product)
#   )

#   redirect_to session.url, allow_other_host: true
# end


def checkout
  @product = Product.find(params[:id])
end

def create_payment_intent
  product = Product.find(params[:id])
  amount = product.price_cents

  payment_intent = Stripe::PaymentIntent.create(
    amount: amount,
    currency: 'inr',
    customer: current_user.stripe_customer_id,
    metadata: {
      product_id: product.id,
      user_id: current_user.id
    },
    automatic_payment_methods: {
      enabled: true
    }
  )

  render json: { client_secret: payment_intent.client_secret }
end


# PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, status: :see_other, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(:name, :price_cents)
    end
end
