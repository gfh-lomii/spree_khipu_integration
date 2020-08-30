module Spree
  class KhipuPaymentReceipt < ActiveRecord::Base
    before_validation :extract_payment_info
    belongs_to :payment, foreign_key: 'transaction_id', primary_key: 'number'

    private

    def extract_payment_info

    end
  end
end
