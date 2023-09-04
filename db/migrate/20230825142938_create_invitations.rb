class CreateInvitations < ActiveRecord::Migration[7.0]
  def change
    create_table :invitations do |t|
      t.string :inviter, null: false
      t.string :invitee
      t.string :invite_digest
      t.datetime :expires_at
      t.string :status

      t.timestamps
    end
  end
end
