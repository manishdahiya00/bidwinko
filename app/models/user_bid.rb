class UserBid < ApplicationRecord
  belongs_to :user
  belongs_to :bid_offer
end
