module Admin
  class BidPlansController < Admin::AdminController
    before_action :authenticate_user!
    before_action :set_bid_plan_category, only: [:show, :edit, :update, :destroy]

    layout "admin"

    def index
      @bidPlans = BidPlan.all.order("id DESC").paginate(:page => params[:page], :per_page => 10)
    end

    def show
    end

    def new
      @bidPlan = BidPlan.new
    end

    def create
      @bidPlan = BidPlan.new(bid_offer_params)
      if @bidPlan.save
        redirect_to admin_bid_plans_path
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @bidPlan.update(bid_offer_params)
        redirect_to admin_bid_plans_path
      else
        render :edit
      end
    end

    def destroy
      @bidPlan.destroy
      redirect_to admin_bid_plans_path
    end

    private

    def set_bid_plan_category
      @bidPlan = BidPlan.find_by(id: params[:id])
    end

    def bid_offer_params
      params.require(:bid_plan).permit(:number_of_bids, :plan_price, :off_percentage, :expires_in, :status, :bid_plan_category_id)
    end
  end
end
