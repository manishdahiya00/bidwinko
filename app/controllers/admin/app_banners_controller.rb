module Admin
  class AppBannersController < Admin::AdminController
    before_action :authenticate_user!

    layout "admin"

    def index
      @appBanners = AppBanner.all.order("id DESC").paginate(:page => params[:page], :per_page => 10)
    end

    def show
      @appBanner = AppBanner.find_by(id: params[:id])
    end

    def new
      @appBanner = AppBanner.new
    end

    def create
      @appBanner = AppBanner.new(app_banner_params)
      if @appBanner.save
        redirect_to admin_app_banner_path(@appBanner)
      else
        render :new
      end
    end

    def edit
      @appBanner = AppBanner.find_by(id: params[:id])
    end

    def update
      @appBanner = AppBanner.find_by(id: params[:id])
      if @appBanner.update(app_banner_params)
        redirect_to admin_app_banner_path(@appBanner)
      else
        render :edit
      end
    end

    def destroy
      @appBanner = AppBanner.find_by(id: params[:id])
      @appBanner.destroy
      redirect_to admin_app_banners_path
    end

    private

    def app_banner_params
      params.require(:app_banner).permit(:image_url, :action_url, :status)
    end
  end
end
