class User < ApplicationRecord
    belongs_to :invitation, optional: true

    has_many :transaction_users
    has_many :transactions, through: :transaction_users
end
