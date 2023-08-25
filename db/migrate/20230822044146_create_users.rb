class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :uid, null: false
      t.string :email
      t.string :name
      t.string :image
      t.references :relationship, null: true, foreign_key: true

      t.timestamps
    end

    add_index :users, :uid, unique: true
  end
end
