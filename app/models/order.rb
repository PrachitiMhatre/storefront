class Order < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :total_amount, :payment_status, presence: true
end
