class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :orders


  after_create :create_stripe_customer

  private

  def create_stripe_customer
    customer = Stripe::Customer.create({
      email: self.email
    })

    update(stripe_customer_id: customer.id)
  end
end
