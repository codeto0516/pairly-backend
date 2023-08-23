class CreateRelationships < ActiveRecord::Migration[7.0]
  def change
    create_table :relationships do |t|
      t.string :uid
      t.references :user_1, null: false, foreign_key: true
      t.references :user_2, null: false, foreign_key: true

      t.timestamps
    end
  end
end
