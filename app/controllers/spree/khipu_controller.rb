module Spree
  class KhipuController < Spree::BaseController
    protect_from_forgery except: [:notify]

    def success
      @payment = Spree::Payment.where(number: params[:payment]).last
      @khipu_receipt = Spree::KhipuPaymentReceipt.create(payment: @payment)
      @payment.order.next!

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
      client    = Khipu::PaymentsApi.new
      response  = client.payments_get(notification_token)

      payment = Spree::Payment.find_by(number: response.transaction_id)

      unless payment.completed? || payment.failed?
        case response.status
        when 'done'
          payment.complete!

          @khipu_receipt = Spree::KhipuPaymentReceipt.where(transaction_id: payment.number).last
          @khipu_receipt.update(params.select{ |k,v| @khipu_receipt.attributes.keys.include? k })
          @khipu_receipt.save!

          head :ok
        else
          payment.failure!
          head :unprocessable_entity
        end
      else
        head :unprocessable_entity
      end
    end

    def completion_route(order, custom_params = nil)
      spree.order_path(order, custom_params)
    end
  end
end
