class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :total_amount
      t.string :payment_status
      t.string :stripe_payment_intent_id

      t.timestamps
    end
  end
end
