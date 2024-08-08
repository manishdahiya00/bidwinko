class BidOffer < ApplicationRecord
  has_many :user_bids, dependent: :destroy
  has_many :closed_bids, dependent: :destroy
  scope :live, -> { where(status: true).order(created_at: :desc).where("? BETWEEN started_at AND ended_at", DateTime.now) }
  scope :upcoming, -> { where(status: true).order(created_at: :desc).where("? < started_at", DateTime.now) }
  scope :completed, -> { where(status: true).order(created_at: :desc).where("? > ended_at", DateTime.now) }
end
