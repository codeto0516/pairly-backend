class Category < ApplicationRecord
  belongs_to :parent, class_name: "Category", optional: true
  has_many :children, class_name: "Category", foreign_key: "parent_id", dependent: :destroy, inverse_of: :parent
  belongs_to :transaction_type

  has_many :transactions, dependent: :destroy
end
