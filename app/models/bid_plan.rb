class BidPlan < ApplicationRecord
  belongs_to :bid_plan_category
  scope :active, -> { where(status: true).order(created_at: :desc) }
end
