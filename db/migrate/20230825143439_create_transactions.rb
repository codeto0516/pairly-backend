class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.date :paid_date
      t.references :category, null: false, default: 1, foreign_key: { to_table: :categories }
      t.string :content
      t.string :created_by, null: false
      t.timestamps
    end
  end
end
