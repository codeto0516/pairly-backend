class Transaction < ApplicationRecord
  belongs_to :category
  has_many :transaction_amounts, dependent: :destroy
  accepts_nested_attributes_for :transaction_amounts
end
