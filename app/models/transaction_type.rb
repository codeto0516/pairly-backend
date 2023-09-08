class TransactionType < ApplicationRecord
  has_many :categories, dependent: :destroy
end
