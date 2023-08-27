class TransactionUser < ApplicationRecord
  belongs_to :related_transaction, class_name: 'Transaction', foreign_key: :transaction_id
  belongs_to :user
end
