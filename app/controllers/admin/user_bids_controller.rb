module Admin
  class UserBidsController < Admin::AdminController
    before_action :authenticate_user!
    layout "admin"

    def index
      @userBids = UserBid.all.order("id DESC").paginate(:page => params[:page], :per_page => 10)
    end
  end
end
