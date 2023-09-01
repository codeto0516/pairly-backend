class CreateInvitations < ActiveRecord::Migration[7.0]
  def change
    create_table :invitations do |t|
      t.string :inviter, null: false
      t.string :invitee, null: false
      t.string :status

      t.timestamps
    end
  end
end
