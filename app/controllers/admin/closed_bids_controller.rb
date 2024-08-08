module Admin
  class ClosedBidsController < Admin::AdminController
    before_action :authenticate_user!
    layout "admin"

    def index
      @closedBids = ClosedBid.all.order("id DESC").paginate(:page => params[:page], :per_page => 10)
    end
  end
end
