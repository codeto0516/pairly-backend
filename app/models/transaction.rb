class Transaction < ApplicationRecord
  belongs_to :category
  belongs_to :created_by, class_name: "User"
  has_many :transaction_users
  has_many :users, through: :transaction_users
end