# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Carts::ProductAdder do
  let(:price) { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
  let(:existing_product) {  create(:product) }
  let(:product) { create(:product, price:) }
  let(:cart) { create(:cart) }
  let(:quantity) { Faker::Number.between(from: 1, to: 10) }
  let(:expected_change) { (price * quantity).to_f }
  let(:service) { described_class.new(cart, product, quantity) }

  describe '#call' do
    context 'when quantity is a non positive number' do
      let(:quantity) { 0 }

      it 'returns failure with corret error message' do
        expect(service.call).to have_attributes(success?: false, error: 'Quantity must be a positive integer')
      end
    end

    context 'when adding a new product' do
      before do
        described_class.new(cart, existing_product, 2).call
      end

      it 'adds cart_item to the cart' do
        expect { service.call }.to change { cart.cart_items.count }.by(1)
      end

      it 'creates cart_item with correct attributes' do
        service.call

        expect(cart.cart_items.last).to have_attributes(
          quantity:,
          unit_purchase_price: product.price
        )
      end

      it 'updates cart total_price' do
        expect { service.call }.to change { cart.total_price }.by(expected_change)
      end

      it 'updates cart last_interaction_at' do
        expect { service.call }.to change { cart.last_interaction_at }
      end

      it 'returns success with correct result' do
        expect(service.call).to have_attributes(success?: true, result: cart)
      end
    end

    context 'when adding an exiting product' do
      before do
        described_class.new(cart, product, 2).call
      end

      it 'adds cart_item to the cart' do
        expect { service.call }.not_to change { cart.cart_items.count }
      end

      it 'updates cart total_price' do
        expect { service.call }.to change { cart.total_price }.by(expected_change)
      end

      it 'updates cart_item quantity' do
        cart_item = cart.cart_items.last

        expect { service.call }.to change { cart_item.reload.quantity }.by(quantity)
      end

      it 'updates cart last_interaction_at' do
        expect { service.call }.to change { cart.last_interaction_at }
      end

      it 'returns success with correct result' do
        expect(service.call).to have_attributes(success?: true, result: cart)
      end
    end
  end
end
