# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartItemSerializer do
  let(:cart_item) { create(:cart_item) }
  let(:serializer) { described_class.new(cart_item) }

  subject { serializer.as_json }

  it 'serializes the cart item with correct attributes' do
    expected_hash = {
        id: cart_item.product_id,
        name: cart_item.product.name,
        quantity: cart_item.quantity,
        unit_price: cart_item.unit_purchase_price,
        total_price: cart_item.total_price
    }

    expect(subject).to match(expected_hash)
  end
end
