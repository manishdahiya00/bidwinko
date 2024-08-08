module Admin
  class TransactionHistoriesController < Admin::AdminController
    before_action :authenticate_user!
    layout "admin"

    def index
      @transactionHistories = TransactionHistory.all.order("id DESC").paginate(:page => params[:page], :per_page => 10)
    end
  end
end
