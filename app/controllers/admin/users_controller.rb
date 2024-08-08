class Admin::UsersController < Admin::AdminController
  before_action :authenticate_user!
  layout "admin"

  def index
    @users = User.all.paginate(page: params[:page], per_page: 20).order(created_at: :desc)
  end

  def show
    @user = User.find(params[:id])
    @appOpens = @user.app_opens.paginate(page: params[:page], per_page: 10).order(created_at: :desc)
    @userBids = @user.user_bids.paginate(page: params[:page], per_page: 10).order(created_at: :desc)
    @transactionHistories = @user.transaction_histories.paginate(page: params[:page], per_page: 10).order(created_at: :desc)
  end
end
