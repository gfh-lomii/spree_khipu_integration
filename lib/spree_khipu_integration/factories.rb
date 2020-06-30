FactoryBot.define do
  # Define your Spree extensions Factories within this file to enable applications, and other extensions to use and override them.
  #
  # Example adding this to your spec_helper will load these Factories for use:
  # require 'spree_khipu_integration/factories'

  factory :khipu_payment_method, class: Spree::PaymentMethod::Khipu do
    name { 'Khipu' }
  end
end
