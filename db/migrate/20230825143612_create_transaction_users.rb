class CreateTransactionUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :transaction_users do |t|
      t.references :transaction, null: false, foreign_key: { to_table: :transactions }
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.integer :amount

      t.timestamps
    end
  end
end
