module API
  module V1
    class Appuser < Grape::API
      include API::V1::Defaults

      resource :home do
        before { api_params }

        params do
          use :common_params
        end
        post do
          begin
            user = valid_user(params[:userId], params[:securityToken])
            return { status: 500, message: INVALID_USER } unless user.present?
            app_banners = []
            AppBanner.active.each do |banner|
              app_banners << {
                id: banner.id,
                image: banner.image_url,
                actionUrl: banner.action_url,
              }
            end
            { status: 200, message: MSG_SUCCESS, appBanners: app_banners || [] }
          rescue Exception => e
            Rails.logger.info "API Exception-#{Time.now}-home-#{params.inspect}-Error-#{e}"
            { status: 500, message: MSG_ERROR }
          end
        end
      end

      resource :upcomingBids do
        before { api_params }

        params do
          use :common_params
        end
        post do
          begin
            user = valid_user(params[:userId], params[:securityToken])
            return { status: 500, message: INVALID_USER } unless user.present?
            upcoming_offers = []
            BidOffer.upcoming.each do |offer|
              upcoming_offers << {
                id: offer.id,
                offerName: offer.offer_name,
                offerPrice: offer.offer_price,
                offerImage: offer.offer_image_url.split(",").first,
                endDate: offer.ended_at.to_i,
                startDate: offer.started_at.to_i,
              }
            end
            { status: 200, message: MSG_SUCCESS, offers: upcoming_offers || [] }
          rescue Exception => e
            Rails.logger.info "API Exception-#{Time.now}-upcomingBids-#{params.inspect}-Error-#{e}"
            { status: 500, message: MSG_ERROR }
          end
        end
      end

      resource :liveBids do
        before { api_params }

        params do
          use :common_params
        end
        post do
          begin
            user = valid_user(params[:userId], params[:securityToken])
            return { status: 500, message: INVALID_USER } unless user.present?
            live_offers = []
            BidOffer.live.each do |offer|
              live_offers << {
                id: offer.id,
                offerName: offer.offer_name,
                offerPrice: offer.offer_price,
                offerImage: offer.offer_image_url.split(",").first,
                endDate: offer.ended_at.to_i,
                startDate: offer.started_at.to_i,
              }
            end
            { status: 200, message: MSG_SUCCESS, offers: live_offers || [] }
          rescue Exception => e
            Rails.logger.info "API Exception-#{Time.now}-liveBids-#{params.inspect}-Error-#{e}"
            { status: 500, message: MSG_ERROR }
          end
        end
      end

      resource :completedBids do
        before { api_params }

        params do
          use :common_params
        end
        post do
          begin
            user = valid_user(params[:userId], params[:securityToken])
            return { status: 500, message: INVALID_USER } unless user.present?
            completed_offers = []
            BidOffer.completed.limit(10).each do |offer|
              completed_offers << {
                id: offer.id,
                offerName: offer.offer_name,
                offerPrice: offer.offer_price,
                offerImage: offer.offer_image_url.split(",").first,
                endDate: offer.ended_at.to_i,
                startDate: offer.started_at.to_i,
              }
            end
            { status: 200, message: MSG_SUCCESS, offers: completed_offers || [] }
          rescue Exception => e
            Rails.logger.info "API Exception-#{Time.now}-completedBids-#{params.inspect}-Error-#{e}"
            { status: 500, message: MSG_ERROR }
          end
        end
      end

      resource :bidDetails do
        before { api_params }

        params do
          use :common_params
          requires :bidId, type: String, allow_blank: false
        end
        post do
          begin
            user = valid_user(params[:userId], params[:securityToken])
            return { status: 500, message: INVALID_USER } unless user.present?
            bid = BidOffer.find_by(id: params[:bidId])
            return { status: 500, message: "INVALID BID" } unless bid.present?
            bidders = UserBid.where(bid_offer_id: bid.id).pluck(:user_id)
            bidder_images = User.where(id: bidders).pluck(:social_img_url)
            bid_hash = {
              productId: bid.id,
              productName: bid.offer_name,
              productImage: bid.offer_image_url.split(","),
              productPrice: bid.offer_price,
              productKeyFeature: bid.offer_desc,
              productEndTime: bid.ended_at.to_i,
              productStartTime: bid.started_at.to_i,
              totalBid: 20,
              bidder: bidder_images || [],
            }
            { status: 200, message: MSG_SUCCESS, bidDetails: bid_hash, totalBids: user.total_bids }
          rescue Exception => e
            Rails.logger.info "API Exception-#{Time.now}-bidDetails-#{params.inspect}-Error-#{e}"
            { status: 500, message: MSG_ERROR }
          end
        end
      end

      resource :placeBid do
        before { api_params }

        params do
          use :common_params
          requires :bidId, type: String, allow_blank: false
          requires :bids, type: Array, allow_blank: false
        end
        post do
          begin
            user = valid_user(params[:userId], params[:securityToken])
            return { status: 500, message: INVALID_USER } unless user.present?
            bid = BidOffer.find_by(id: params[:bidId])
            return { status: 500, message: "INVALID BID" } unless bid.present?
            user.user_bids.create(bid_offer_id: bid.id, bids: params[:bids])
            if user.total_bids.to_i <= 0
              return { status: 500, message: "INSUFFICIENT BIDS" }
            end
            total_bids = user.total_bids.to_i - params[:bids].size
            user.update(total_bids: total_bids)
            { status: 200, message: MSG_SUCCESS, remainingBids: user.total_bids }
          rescue Exception => e
            Rails.logger.info "API Exception-#{Time.now}-placeBid-#{params.inspect}-Error-#{e}"
            { status: 500, message: MSG_ERROR }
          end
        end
      end

      resource :userProductBids do
        before { api_params }

        params do
          use :common_params
          requires :bidId, type: String, allow_blank: false
        end
        post do
          begin
            user = valid_user(params[:userId], params[:securityToken])
            return { status: 500, message: INVALID_USER } unless user.present?
            bid = BidOffer.find_by(id: params[:bidId])
            return { status: 500, message: "INVALID BID" } unless bid.present?
            cancelled_bids = []
            user_bids = user.user_bids.where(bid_offer_id: bid.id)
            other_bids = UserBid.where.not(user_id: user.id).flat_map(&:bids).map(&:to_s)
            user_bids.each do |user_bid|
              user_bid.bids.each do |b|
                if other_bids.include?(b.to_s) && b.to_s != bid.id.to_s
                  cancelled_bids << b
                end
              end
            end
            {
              status: 200,
              message: MSG_SUCCESS,
              userBids: user_bids.map(&:bids).flatten,
              cancelledBids: cancelled_bids.uniq,
            }
          rescue StandardError => e
            Rails.logger.info "API Exception-#{Time.now}-userProductBids-#{params.inspect}-Error-#{e.message}"
            { status: 500, message: MSG_ERROR }
          end
        end
      end

      resource :buyBids do
        before { api_params }

        params do
          use :common_params
        end
        post do
          begin
            user = valid_user(params[:userId], params[:securityToken])
            return { status: 500, message: INVALID_USER } unless user.present?
            bid_plans = []
            BidPlanCategory.active.each do |category|
              plans_data = category.bid_plans.active.map do |plan|
                {
                  planId: plan.id,
                  noOfBids: plan.number_of_bids,
                  expiresIn: plan.expires_in,
                  offPercentage: plan.off_percentage,
                  planPrice: plan.plan_price,
                }
              end
              bid_plans << {
                categoryId: category.id,
                categoryTitle: category.title,
                plans: plans_data,
              }
            end
            { status: 200, message: MSG_SUCCESS, totalBids: user.total_bids, bidPlans: bid_plans || [] }
          rescue Exception => e
            Rails.logger.info "API Exception-#{Time.now}-buyBids-#{params.inspect}-Error-#{e}"
            { status: 500, message: MSG_ERROR }
          end
        end
      end

      resource :buyBid do
        before { api_params }

        params do
          use :common_params
          requires :paymentId, type: String, allow_blank: false
          requires :orderId, type: String, allow_blank: false
          requires :receipt, type: String, allow_blank: false
          requires :amount, type: String, allow_blank: false
          requires :numberOfBids, type: String, allow_blank: false
        end
        post do
          begin
            user = valid_user(params[:userId], params[:securityToken])
            return { status: 500, message: INVALID_USER } unless user.present?
            user.transaction_histories.create(amount: params[:amount], payment_id: params[:paymentId], order_id: params[:orderId], receipt: params[:receipt], title: "Bids Purchased")
            { status: 200, message: MSG_SUCCESS, success: true }
          rescue Exception => e
            Rails.logger.info "API Exception-#{Time.now}-buyBids-#{params.inspect}-Error-#{e}"
            { status: 500, message: MSG_ERROR }
          end
        end
      end

      resource :myBids do
        before { api_params }

        params do
          use :common_params
          requires :bidId, type: String, allow_blank: false
        end
        post do
          begin
            user = valid_user(params[:userId], params[:securityToken])
            return { status: 500, message: INVALID_USER } unless user.present?
            bid = BidOffer.find_by id: params[:bidId]
            return { status: 500, message: "INVALID BID" } unless bid.present?
            user_bids = user.user_bids.where(bid_offer_id: bid.id)
            other_bids = UserBid.where.not(user_id: user.id).flat_map(&:bids).map(&:to_s)
            bids_with_status = []

            user_bids.each do |user_bid|
              user_bid.bids.each do |b|
                bid_no_str = b.to_s
                bids_with_status << {
                  bidNo: bid_no_str,
                  status: other_bids.include?(bid_no_str) && bid_no_str != bid.id.to_s ? "Cancelled" : "Unique",
                }
              end
            end
            user_bids_with_status = bids_with_status.uniq { |b| b[:bidNo] }.sort_by { |b| b[:bidNo] }
            {
              status: 200,
              message: MSG_SUCCESS,
              bidImage: bid.offer_image_url.split(",").first,
              bidTitle: bid.offer_name,
              startDate: bid.started_at.strftime("%d/%m/%y %I:%M %p"),
              endDate: bid.ended_at.strftime("%d/%m/%y %I:%M %p"),
              bids: user_bids_with_status,
            }
          rescue Exception => e
            Rails.logger.info "API Exception-#{Time.now}-myBids-#{params.inspect}-Error-#{e}"
            { status: 500, message: MSG_ERROR }
          end
        end
      end

      resource :transactionHistory do
        before { api_params }

        params do
          use :common_params
        end
        post do
          begin
            user = valid_user(params[:userId], params[:securityToken])
            return { status: 500, message: INVALID_USER } unless user.present?
            transactions = []
            user.transaction_histories.order(created_at: :desc).limit(30).each_with_index do |transaction, index|
              transactions << {
                serialNo: index + 1,
                title: transaction.title,
                amount: !transaction.amount.nil? ? "₹ #{transaction.amount}" : "FREE",
                date: transaction.created_at.strftime("%d/%m/%y"),
                time: transaction.created_at.strftime("%I:%M %p"),
                bids: transaction.number_of_bids,
              }
            end
            { status: 200, message: MSG_SUCCESS, transactions: transactions || [] }
          rescue Exception => e
            Rails.logger.info "API Exception-#{Time.now}-transactionHistory-#{params.inspect}-Error-#{e}"
            { status: 500, message: MSG_ERROR }
          end
        end
      end

      resource :closedBidWinner do
        before { api_params }

        params do
          use :common_params
          requires :bidId, type: String, allow_blank: false
        end

        post do
          begin
            user = valid_user(params[:userId], params[:securityToken])
            return { status: 500, message: INVALID_USER } unless user.present?

            bid = BidOffer.find_by(id: params[:bidId])
            return { status: 500, message: "INVALID BID" } unless bid.present?

            all_bids = UserBid.where(bid_offer_id: params[:bidId])
                              .flat_map { |user_bid| user_bid.bids.map { |bid_value| { bid: bid_value.to_f, user: user_bid.user_id } } }

            # Rails.logger.info "All Bids: #{all_bids.inspect}"

            bids_by_value = all_bids.group_by { |b| b[:bid] }
            duplicate_bids = bids_by_value.select { |bid_value, bids| bids.size > 1 }.keys

            # Rails.logger.info "Duplicate Bids: #{duplicate_bids.inspect}"

            valid_bids = all_bids.reject { |b| duplicate_bids.include?(b[:bid]) }

            # Rails.logger.info "Valid Bids: #{valid_bids.inspect}"

            user_bids = valid_bids.group_by { |b| b[:user] }.map do |user, bids|
              { user: user, bid: bids.min_by { |b| b[:bid] }[:bid] }
            end

            # Rails.logger.info "User Bids (Lowest per User): #{user_bids.inspect}"

            sorted_bids = user_bids.sort_by { |b| b[:bid] }

            # Rails.logger.info "Sorted Bids: #{sorted_bids.inspect}"

            selected_bids = sorted_bids.first(3)

            # Rails.logger.info "Initially Selected Bids: #{selected_bids.inspect}"

            user_details = User.where(id: selected_bids.map { |bid| bid[:user] })
                               .pluck(:id, :social_name, :social_img_url)
                               .to_h { |id, social_name, social_img_url| [id, { id: id, social_name: social_name, social_img_url: social_img_url }] }

            # Rails.logger.info "User Details: #{user_details.inspect}"

            formatted_bids = selected_bids.each_with_index.map do |bid, index|
              {
                position: index + 1,
                id: user_details[bid[:user]][:id],
                name: user_details[bid[:user]][:social_name],
                image: user_details[bid[:user]][:social_img_url],
                prize: case index
                when 0 then "Winner"
                when 1 then "20 Bids"
                when 2 then "12 Bids"
                end,
              }
            end

            # Rails.logger.info "Formatted Bids: #{formatted_bids.inspect}"

            closed_bid = ClosedBid.find_or_initialize_by(bid_offer_id: params[:bidId])
            closed_bid.update(lowest_bid: selected_bids.first, winners: formatted_bids)

            productDetail = {
              productImage: bid.offer_image_url.split(",") || [],
              productKeyFeature: bid.offer_desc,
              productName: bid.offer_name,
              productPrice: bid.offer_price,
              productEndTime: bid.ended_at.strftime("%d/%m/%y %I:%M %p"),
            }

            {
              status: 200,
              message: MSG_SUCCESS,
              winnersList: formatted_bids || [],
              productDetail: productDetail || {},
            }
          rescue StandardError => e
            Rails.logger.info "API Exception-#{Time.now}-closedBidWinners-#{params.inspect}-Error-#{e.message}"
            { status: 500, message: MSG_ERROR }
          end
        end
      end

      resource :profile do
        before { api_params }

        params do
          use :common_params
          requires :email, type: String, allow_blank: true
          requires :name, type: String, allow_blank: true
          requires :phone, type: String, allow_blank: true
          requires :address, type: String, allow_blank: true
          requires :method, type: String, allow_blank: false
        end
        post do
          begin
            user = valid_user(params[:userId], params[:securityToken])
            return { status: 500, message: INVALID_USER } unless user.present?
            if params[:method] == "GET"
              { status: 200, message: MSG_SUCCESS, userEmail: user.social_email, userName: user.social_name, mobileNumber: user.mobile_number, address: user.address, userImage: user.social_img_url }
            else
              email = params[:email].presence || user.social_email
              name = params[:name].presence || user.social_name
              phone = params[:phone].presence || user.mobile_number
              address = params[:address].presence || user.address
              user.update(social_email: email, social_name: name, mobile_number: phone, address: address)
              { status: 200, message: MSG_SUCCESS, userEmail: user.social_email, userName: user.social_name, mobileNumber: user.mobile_number, address: user.address, userImage: user.social_img_url }
            end
          rescue Exception => e
            Rails.logger.info "API Exception-#{Time.now}-bidDetails-#{params.inspect}-Error-#{e}"
            { status: 500, message: MSG_ERROR }
          end
        end
      end

      resource :bidPastWinners do
        before { api_params }

        params do
          use :common_params
        end
        post do
          begin
            user = valid_user(params[:userId], params[:securityToken])
            return { status: 500, message: INVALID_USER } unless user.present?
            winner_details = []
            ClosedBid.order(created_at: :desc).limit(30).each do |winner|
              if winner.lowest_bid
                lowest_bid_detail = eval(winner.lowest_bid)
                user_detail = User.find_by(id: lowest_bid_detail[:user])
                bid_offer = BidOffer.find_by(id: winner.bid_offer_id)
                winner_details << {
                  user_Name: user_detail.social_name,
                  user_Image: user_detail.social_img_url,
                  product_Name: bid_offer.offer_name,
                  product_Image: bid_offer.offer_image_url.split(",").first,
                  price: bid_offer.offer_price,
                  winnning_Bid: lowest_bid_detail[:bid],
                  location: user_detail.address,
                }
              end
            end

            { message: MSG_SUCCESS, status: 200, winner_details: winner_details || [] }
          rescue StandardError => e
            Rails.logger.error "API Exception-#{Time.now}-bidPastWinners-#{params.inspect}-Error-#{e.message}"
            { status: 500, message: MSG_ERROR }
          end
        end
      end

      resource :appInvite do
        before { api_params }

        params do
          use :common_params
        end

        post do
          begin
            user = valid_user(params[:userId], params[:securityToken])
            return { status: 500, message: INVALID_USER } unless user.present?
            { status: 200, message: MSG_SUCCESS, referralCode: user.refer_code, totalBids: user.total_bids, inviteUrl: "https://www.bidwin.co.in/invite" }
          rescue Exception => e
            Rails.logger.info "API Exception-#{Time.now}-appInvite-#{params.inspect}-Error-#{e}"
            { status: 500, message: MSG_ERROR, error: e }
          end
        end
      end

      resource :payment do
        before { api_params }

        params do
          use :common_params
          requires :planId, type: String, allow_blank: false
        end

        post do
          begin
            user = valid_user(params[:userId], params[:securityToken])
            return { status: 500, message: INVALID_USER } unless user.present?
            plan = BidPlan.find_by(id: params[:planId])
            return { status: 500, message: "INVALID PLAN" } unless plan.present?
            require "rest-client"
            require "base64"
            orderId = SecureRandom.hex(8)
            response = RestClient.post(
              "https://api.viccas.in/Api/v1.0/Payment",
              {
                orderId: SecureRandom.hex(8),
                amount: plan.plan_price,
                customer_name: user.social_name,
                customer_mobile: "919817850944",
                customer_email: user.social_email,
                currency: "INR",
                expire_by: 0,
                sms_notify: true,
                email_notify: true,
                partial_payment: false,
                additional_field1: "",
                additional_field2: "",
                redirect_url: "https://www.bidwin.co.in/payment",
                dueDate: Date.tomorrow,
              }.to_json,
              {
                Authorization: "Basic #{Base64.strict_encode64("hylo_4984_bcbf6146df5cc9ba:$2a$10$gvzWDkrIsdghTLjHEAi59.yOV")}",
                content_type: :json,
                accept: :json,
              }
            )
            res = JSON.parse(response.body)
            if res["short_url"].present?
              @total_bids = user.total_bids.to_i + plan.number_of_bids.to_i
              user.update(total_bids: @total_bids)
              { status: 200, message: MSG_SUCCESS, url: res["short_url"] }
            else
              { status: 500, message: MSG_ERROR, error: "NO URL PRESENT" }
            end
          rescue Exception => e
            Rails.logger.info "API Exception-#{Time.now}-appInvite-#{params.inspect}-Error-#{e}"
            { status: 500, message: MSG_ERROR, error: e }
          end
        end
      end
    end
  end
end
