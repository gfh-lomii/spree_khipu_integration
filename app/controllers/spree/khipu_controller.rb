module Spree
  class KhipuController < Spree::BaseController
    protect_from_forgery except: [:notify, :continue]

    def notify
      notification_token = params["notification_token"]
      client    = Khipu::PaymentsApi.new
      response  = client.payments_get(notification_token)

      order = Spree::Order.find(response.transaction_id)
      payment = order.payments.last

      unless payment.completed? || payment.failed?
        case response.status
        when 'done'
          payment.complete!
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
