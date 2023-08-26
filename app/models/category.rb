class Category < ApplicationRecord
  belongs_to :parent, class_name: "Category", optional: true
  belongs_to :transaction_type

  has_many :transactions

end
