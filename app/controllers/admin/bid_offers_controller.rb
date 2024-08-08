module Admin
  class BidOffersController < Admin::AdminController
    before_action :authenticate_user!
    before_action :set_bid_offer, only: [:show, :edit, :update, :destroy]

    layout "admin"

    def index
      @bidOffers = BidOffer.all.order("id DESC").paginate(:page => params[:page], :per_page => 10)
    end

    def show
    end

    def new
      @bidOffer = BidOffer.new
    end

    def create
      @bidOffer = BidOffer.new(bid_offer_params)
      if @bidOffer.save
        redirect_to admin_bid_offer_path(@bidOffer)
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @bidOffer.update(bid_offer_params)
        redirect_to admin_bid_offer_path(@bidOffer)
      else
        render :edit
      end
    end

    def destroy
      @bidOffer.destroy
      redirect_to admin_bid_offers_path
    end

    private

    def set_bid_offer
      @bidOffer = BidOffer.find_by(id: params[:id])
    end

    def bid_offer_params
      params.require(:bid_offer).permit(:offer_name, :offer_price, :started_at, :ended_at, :offer_image_url, :offer_video_url, :offer_desc, :status)
    end
  end
end
