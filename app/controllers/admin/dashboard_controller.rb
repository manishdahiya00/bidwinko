module Admin
  class DashboardController < Admin::AdminController
    before_action :authenticate_user!
    layout "admin"

    def index
      @users = User.count
      @app_banners = AppBanner.count
      @bid_offers = BidOffer.count
      @bidPlanCategories = BidPlanCategory.count
      @bidPlans = BidPlan.count
      @userBids = UserBid.count
      @transactionHistories = TransactionHistory.count
      @closedBids = ClosedBid.count
    end
  end
end
