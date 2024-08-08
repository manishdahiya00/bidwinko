class MainController < ApplicationController
  def index
  end

  def payment
    @payment_status = "success"
    @order_id = "OSDISS6845IDO5558ADSD"
    @number_of_bids = "20"
    @total_amount = "200"
  end
end
