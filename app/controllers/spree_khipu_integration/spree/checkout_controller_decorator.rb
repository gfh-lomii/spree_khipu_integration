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
        api = Khipu::PaymentsApi.new
        response  = api.payments_post(
          KhipuOrder.description,
          KhipuOrder.currency(@order),
          KhipuOrder.amount(@order),
          KhipuOrder.options(@order, order_url(@order), khipu_notify_url)
        )

        if response
          redirect_to response.payment_url if payment_success(payment_method)
        else
          khipu_error
        end
      end

    rescue StandardError => e
      khipu_error(e)
    end

    def payment_success(payment_method)
      payment = @order.payments.build(
        payment_method_id: payment_method.id,
        amount: @order.total,
        state: 'checkout'
      )

      unless payment.save
        flash[:error] = payment.errors.full_messages.join("\n")
        redirect_to checkout_state_path(@order.state) and return
      end

      unless @order.next
        flash[:error] = @order.errors.full_messages.join("\n")
        redirect_to checkout_state_path(@order.state) and return
      end

      payment.pend!
    end

    def khipu_error(e = nil)
      @order.errors[:base] << "Khipu error #{e.try(:message)}"
      render :edit
    end
  end
end

::Spree::CheckoutController.prepend SpreeKhipuIntegration::Spree::CheckoutControllerDecorator
