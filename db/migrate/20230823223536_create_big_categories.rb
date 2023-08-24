class CreateBigCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :big_categories do |t|
      t.string :name, null: false
      t.references :transaction_type, null: false, foreign_key: true

      t.timestamps
    end

    # add_index :big_categories, :name, unique: true
  end
end
