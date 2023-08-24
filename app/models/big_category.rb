class BigCategory < ApplicationRecord
  belongs_to :transaction_type
  has_many :small_categories
end
