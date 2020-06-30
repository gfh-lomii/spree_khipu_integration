module Spree
  class KhipuController < Spree::BaseController
    protect_from_forgery except: [:notify, :continue]

    def notify
      notification_token = params["notification_token"]
      client    = Khipu::PaymentsApi.new
      response  = client.payments_get(notification_token)

      payment = Spree::Payment.find_by(number: response.transaction_id)

      unless payment.completed? || payment.failed?
        case response.status
        when 'done'
          payment.complete!
          payment.order.next
          head :ok
        else
          payment.failure!
          head :unprocessable_entity
        end
      else
        head :unprocessable_entity
      end
    end
  end
end
