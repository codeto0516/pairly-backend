class CreateTransactionUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :transaction_amounts do |t|
      t.references :transaction, null: false, foreign_key: { to_table: :transactions }
      t.string :uid, null: false
      t.integer :amount

      t.timestamps
    end
  end
end
