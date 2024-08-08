class CreateBidPlans < ActiveRecord::Migration[7.1]
  def change
    create_table :bid_plans do |t|
      t.string :number_of_bids
      t.string :expires_in
      t.string :off_percentage
      t.string :plan_price
      t.references :bid_plan_category
      t.boolean :status, default: true

      t.timestamps
    end
  end
end
