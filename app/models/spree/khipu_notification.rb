module Spree
  class KhipuNotification < Spree::Base
    belongs_to :order, class_name: 'Spree::Order'
    belongs_to :payment, class_name: 'Spree::Payment'
  end
end
