class CreateSmallCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :small_categories do |t|
      t.string :name
      t.references :big_category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
