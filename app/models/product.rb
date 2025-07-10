class Product < ApplicationRecord
	include Elasticsearch::Model
  	include Elasticsearch::Model::Callbacks

  	has_one_attached :image
  	has_many :orders

	# Optional: customize the index mapping
	settings index: { number_of_shards: 1 } do
		mappings dynamic: false do
		  indexes :name, type: :text
		  indexes :price_cents, type: :integer
		end
	end
end
