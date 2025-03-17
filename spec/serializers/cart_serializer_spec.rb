# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartSerializer do
  let(:cart) { create(:cart) }
  let(:cart_item1) { create(:cart_item, cart: cart) }
  let(:cart_item2) { create(:cart_item, cart: cart) }
  let(:serializer) { described_class.new(cart) }

  subject { serializer.as_json }

  it 'serializes the cart with correct attributes' do
    expected_hash = {
      id: cart.id,
      products: subject[:products],
      total_price: cart.total_price
    }

    expect(subject.except(:products)).to match(expected_hash.except(:products))
    expect(subject.keys).to match_array([:id, :products, :total_price])
  end

  it 'serializes the cart with associated cart items' do
    expected_products = [
      {
        id: cart_item1.product_id,
        name: cart_item1.product.name,
        quantity: cart_item1.quantity,
        unit_price: cart_item1.unit_purchase_price,
        total_price: cart_item1.total_price
      },
      {
        id: cart_item2.product_id,
        name: cart_item2.product.name,
        quantity: cart_item2.quantity,
        unit_price: cart_item2.unit_purchase_price,
        total_price: cart_item2.total_price
      }
    ]

    expect(subject[:products]).to match_array(expected_products)
  end
end
