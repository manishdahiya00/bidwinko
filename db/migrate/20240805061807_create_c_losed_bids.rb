class CreateCLosedBids < ActiveRecord::Migration[7.1]
  def change
    create_table :closed_bids do |t|
      t.references :bid_offer, null: false, foreign_key: true
      t.string :lowest_bid
      t.string :winner1_city, default: "New Delhi"
      t.string :winner2_city, default: "New Delhi"
      t.string :winner3_city, default: "New Delhi"
      t.string :winner1_state, default: "Delhi"
      t.string :winner2_state, default: "Delhi"
      t.string :winner3_state, default: "Delhi"
      t.json :winners

      t.timestamps
    end
  end
end
