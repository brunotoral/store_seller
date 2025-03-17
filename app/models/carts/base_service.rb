# frozen_string_literal: true

module Carts
  class BaseService
    include ServiceResult

    def initialize(cart, product)
      @cart = cart
      @product = product
      @increment_amount = 0
    end

    def call
      raise NotImplementedError, 'This method sould be implemented'
    end

    private

      attr_reader :cart, :product, :increment_amount


      def update_cart_total
        cart.last_interaction_at = Time.current
        cart.total_price += increment_amount
        cart.save!
      end
  end
end
