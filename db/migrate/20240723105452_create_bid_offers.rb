class CreateBidOffers < ActiveRecord::Migration[7.1]
  def change
    create_table :bid_offers do |t|
      t.string :offer_name
      t.string :offer_price
      t.datetime :started_at
      t.datetime :ended_at
      t.string :offer_image_url
      t.string :offer_video_url
      t.text :offer_desc
      t.boolean :status

      t.timestamps
    end
  end
end
