class CreateUserBids < ActiveRecord::Migration[7.1]
  def change
    create_table :user_bids do |t|
      t.references :user, null: false, foreign_key: true
      t.references :bid_offer, null: false, foreign_key: true
      t.json :bids

      t.timestamps
    end
  end
end
