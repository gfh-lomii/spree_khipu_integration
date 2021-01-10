module Spree
  class KhipuController < Spree::BaseController
    protect_from_forgery except: [:notify]
    layout 'spree/layouts/redirect', only: :success

    def success
      @payment = Spree::Payment.where(number: params[:payment]).last
      return unless @payment.order.completed?

      @current_order = nil
      unless KhipuNotification.find_by(order_id: @payment.order_id, payment_id: @payment.id)
        flash.notice = Spree.t(:order_processed_successfully)
        flash['order_completed'] = true
      end

      KhipuNotification.create(order_id: @payment.order_id, payment_id: @payment.id)
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
          order = payment.order
          order.skip_stock_validation = true
          payment.order.next!

          @khipu_receipt = Spree::KhipuPaymentReceipt.where(transaction_id: payment.number).last
          @khipu_receipt.update(params.select { |k, v| @khipu_receipt.attributes.keys.include? k })
          @khipu_receipt.save
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
