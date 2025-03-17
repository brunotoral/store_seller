# frozen_string_literal: true

module Carts
  class ProductRemover < Carts::BaseService
    def call
      ActiveRecord::Base.transaction do
        return failure('The cart must exists') unless cart

        cart_item = find_cart_item

        return failure('Product is not in the cart') unless cart_item

        remove_cart_item(cart_item)

        update_cart_total if cart.persisted?
      end

      cart.destroyed? ? success({}) : success(cart)
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
      failure(e.message)
    end

    private

      def find_cart_item
        cart.cart_items.find_by(product: product)
      end

      def remove_cart_item(cart_item)
        return if destroy_cart_if_only_item(cart_item)

        @increment_amount = -(cart_item.total_price)

        cart_item.destroy!
      end

      def destroy_cart_if_only_item(cart_item)
        cart_items = cart.cart_items

        cart.destroy! if cart_items.one? && cart_items.first == cart_item
      end
  end
end
