class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :uid, null: false
      t.string :email
      t.string :name
      t.string :image

      t.timestamps
    end
  end
end
