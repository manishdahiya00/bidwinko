class ChnageBidOfferImageUrl < ActiveRecord::Migration[7.1]
  def change
    change_column :bid_offers, :offer_image_url, :text
  end
end
