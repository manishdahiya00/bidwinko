module Admin
  class BidPlanCategoriesController < Admin::AdminController
    before_action :authenticate_user!
    before_action :set_bid_plan_category, only: [:show, :edit, :update, :destroy]

    layout "admin"

    def index
      @bidPlanCategories = BidPlanCategory.all.order("id DESC").paginate(:page => params[:page], :per_page => 10)
    end

    def show
    end

    def new
      @bidPlanCategory = BidPlanCategory.new
    end

    def create
      @bidPlanCategory = BidPlanCategory.new(bid_offer_params)
      if @bidPlanCategory.save
        redirect_to admin_bid_plan_categories_path
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @bidPlanCategory.update(bid_offer_params)
        redirect_to admin_bid_plan_categories_path
      else
        render :edit
      end
    end

    def destroy
      @bidPlanCategory.destroy
      redirect_to admin_bid_plan_categories_path
    end

    private

    def set_bid_plan_category
      @bidPlanCategory = BidPlanCategory.find_by(id: params[:id])
    end

    def bid_offer_params
      params.require(:bid_plan_category).permit(:title, :status)
    end
  end
end
