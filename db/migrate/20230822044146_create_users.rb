class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :uid
      t.references :relationship, null: true, foreign_key: true

      t.timestamps
    end
  end
end
