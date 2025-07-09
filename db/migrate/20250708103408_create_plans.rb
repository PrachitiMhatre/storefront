class CreatePlans < ActiveRecord::Migration[7.1]
  def change
    create_table :plans do |t|
      t.string :name
      t.integer :price_cents
      t.string :stripe_price_id

      t.timestamps
    end
  end
end
