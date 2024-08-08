class BidPlanCategory < ApplicationRecord
  has_many :bid_plans, dependent: :destroy
  scope :active, -> { where(status: true).order(created_at: :desc) }
end
