class CreateInvitations < ActiveRecord::Migration[7.0]
  def change
    create_table :invitations do |t|
      t.references :inviter, null: false, foreign_key: { to_table: :users }
      t.references :invitee, foreign_key: { to_table: :users }
      t.string :status

      t.timestamps
    end
  end
end
