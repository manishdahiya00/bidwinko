module Admin
  class ClosedBidsController < Admin::AdminController
    before_action :authenticate_user!
    layout "admin"

    def index
      @closedBids = ClosedBid.all.order("id DESC").paginate(:page => params[:page], :per_page => 10)
    end

    def edit
      @closedBid = ClosedBid.find_by(id: params[:id])
    end

    def update
      @closedBid = ClosedBid.find_by(id: params[:id])
      if @closedBid.update(closed_bid_params)
        redirect_to admin_closed_bids_path
      else
        render :edit
      end
    end

    def closed_bid_params
      params.require(:closed_bid).permit(:winner1_city, :winner2_city, :winner3_city, :winner1_state, :winner2_state, :winner3_state)
    end
  end
end
