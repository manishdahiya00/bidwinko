class CreateBidPlanCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :bid_plan_categories do |t|
      t.boolean :status, default: true
      t.string :title

      t.timestamps
    end
  end
end
