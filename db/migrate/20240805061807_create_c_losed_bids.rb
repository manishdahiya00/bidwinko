class CreateCLosedBids < ActiveRecord::Migration[7.1]
  def change
    create_table :closed_bids do |t|
      t.references :bid_offer, null: false, foreign_key: true
      t.string :lowest_bid
      t.json :winners

      t.timestamps
    end
  end
end
