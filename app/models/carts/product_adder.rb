# frozen_string_literal: true

module Carts
  class ProductAdder < Carts::BaseService
    def initialize(cart, product, quantity)
      super(cart, product)
      @quantity = quantity
    end

    def call
      return failure('Quantity must be a positive integer') unless quantity.positive?

      ActiveRecord::Base.transaction do
        cart_item = find_or_initialize_cart_item

        add_cart_item(cart_item)
        update_cart_total
      end

      success(cart)
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
      failure(e.message)
    end

    private

      attr_reader :quantity

      def find_or_initialize_cart_item
        cart.cart_items.find_or_initialize_by(product:)
      end

      def add_cart_item(cart_item)
        cart_item.unit_purchase_price = product.price if cart_item.new_record?
        cart_item.quantity += quantity

        cart_item.save!

        @increment_amount = cart_item.unit_purchase_price * quantity
      end
  end
end
