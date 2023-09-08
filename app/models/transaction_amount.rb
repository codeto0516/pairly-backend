class TransactionAmount < ApplicationRecord
  belongs_to :related_transaction, class_name: 'Transaction', foreign_key: :transaction_id, inverse_of: :transaction_amounts
end
