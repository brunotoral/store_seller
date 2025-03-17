# frozen_string_literal: true

class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :unit_purchase_price, numericality: { greater_than: 0 }


  def total_price
    unit_purchase_price * quantity
  end
end
