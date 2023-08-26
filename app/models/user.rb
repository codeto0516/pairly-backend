class User < ApplicationRecord
    belongs_to :invitation

    has_many :transaction_users
    has_many :transactions, through: :transaction_users
end
