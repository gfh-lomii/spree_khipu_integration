module Spree
  class KhipuController < Spree::BaseController
    protect_from_forgery except: [:notify]
    layout 'spree/layouts/redirect', only: :success

    def success
      @payment = Spree::Payment.where(number: params[:payment]).last

      if @payment.order.completed?
        @current_order = nil
        redirect_to completion_route(@payment.order)
      end

      begin
        @payment.order.next!
      rescue
        return
      end

      @khipu_receipt = Spree::KhipuPaymentReceipt.create(payment: @payment)
      @current_order = nil
      flash.notice = Spree.t(:order_processed_successfully)
      flash['order_completed'] = true

      redirect_to completion_route(@payment.order)
    end

    def cancel
      @payment = Spree::Payment.where(number: params[:payment]).last
      @khipu_receipt = Spree::KhipuPaymentReceipt.create(payment: @payment)

      redirect_to checkout_state_path(:payment) and return
    end

    def notify
      notification_token = params["notification_token"]
      client = Khipu::PaymentsApi.new
      response = client.payments_get(notification_token)

      payment = Spree::Payment.find_by(number: response.transaction_id)

      unless payment.completed? || payment.failed?
        case response.status
        when 'done'
          payment.complete!

          @khipu_receipt = Spree::KhipuPaymentReceipt.where(transaction_id: payment.number).last
          @khipu_receipt.update(params.select { |k, v| @khipu_receipt.attributes.keys.include? k })
          @khipu_receipt.save!
        else payment.failure!
        end
      end
      head :ok
    rescue
      head :unprocessable_entity
    end

    def completion_route(order, custom_params = nil) spree.order_path(order, custom_params)
    end
  end
end
