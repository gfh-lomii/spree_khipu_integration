module SpreeKhipuIntegration::Spree
  module CheckoutControllerDecorator
    def self.prepended(base)
      base.before_action :pay_with_khipu, only: :update
    end

    private

    def pay_with_khipu
      return unless params[:state] == 'payment'
      return if params[:order].blank? || params[:order][:payments_attributes].blank?

      pm_id = params[:order][:payments_attributes].first[:payment_method_id]
      payment_method = Spree::PaymentMethod.find(pm_id)

      if payment_method && payment_method.kind_of?(Spree::PaymentMethod::Khipu)
        payment_number = khipu_create_payment(payment_method)
        khipu_error and return unless payment_number.present?

        api = Khipu::PaymentsApi.new
        response  = api.payments_post(
          KhipuOrder.description,
          KhipuOrder.currency(@order),
          KhipuOrder.amount(@order),
          KhipuOrder.options(@order, payment_number, khipu_success_url(payment_number), khipu_notify_url, khipu_cancel_url(payment_number))
        )

        puts payment_number
        puts khipu_success_url(payment_number)
        puts khipu_notify_url
        puts khipu_cancel_url(payment_number)

        if response
          payment_url = :payment_url if payment_method.preferences[:checkout_khipu]
          payment_url = :webpay_url if payment_method.preferences[:checkout_webpay]
          redirect_to response.send(payment_url)
        else
          khipu_error
        end
      end

    rescue StandardError => e
      khipu_error(e)
    end

    def khipu_create_payment(payment_method)
      payment = @order.payments.build(payment_method_id: payment_method.id, amount: @order.total, state: 'checkout')

      unless payment.save
        flash[:error] = payment.errors.full_messages.join("\n")
        redirect_to checkout_state_path(@order.state) and return
      end

      unless payment.pend!
        flash[:error] = payment.errors.full_messages.join("\n")
        redirect_to checkout_state_path(@order.state) and return
      end

      payment.number
    end

    def khipu_error(e = nil)
      @order.errors[:base] << "Khipu error #{e.try(:message)}"
      render :edit
    end
  end
end

::Spree::CheckoutController.prepend SpreeKhipuIntegration::Spree::CheckoutControllerDecorator
