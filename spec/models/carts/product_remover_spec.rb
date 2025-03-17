# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Carts::ProductRemover do
  let(:price) { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
  let(:existing_product) {  create(:product) }
  let(:product) { create(:product, price:) }
  let(:cart) { create(:cart) }
  let(:quantity) { Faker::Number.between(from: 1, to: 10) }
  let(:expected_change) { (price * quantity).to_f }
  let(:service) { described_class.new(cart, product) }

  describe '#call' do
    context 'when the product exists in the cart' do
      let(:quantity) { 2 }

      before do
        create(:cart_item, cart:, product: existing_product, quantity:)
        create(:cart_item, cart:, product:, quantity:)
        cart.update!(total_price: cart.calculate_total_price)
      end

      it 'destroy the cart_item record' do
        expect { service.call }.to change { CartItem.count}.by(-1)
      end

      it 'updates cart total_price' do
        expected_changed_amount = (price * quantity).to_d

        expect { service.call }.to change { cart.total_price }.by(-expected_changed_amount)
      end

      it 'updates cart last_interaction_at' do
        expect { service.call }.to change { cart.last_interaction_at }
      end

      it 'returns success with correct result' do
        expect(service.call).to have_attributes(success?: true, result: cart)
      end
    end

    context 'when there are no cart_items left in the cart' do
      before do
        create(:cart_item, cart:, product:, quantity:)
      end

      it 'destroy the cart' do
        expect { service.call }.to change { Cart.count }.by(-1)
      end

      it 'returns success with empty result' do
        expect(service.call).to have_attributes(success?: true, result: {})
      end
    end

    context 'when the product does not exists in the cart' do
      let(:service) { described_class.new(cart, existing_product.id) }

      it 'returns failure with correct result' do
        expect(service.call).to have_attributes(success?: false, error: 'Product is not in the cart' )
      end
    end
    context 'when the product does not exists' do
      let(:service) { described_class.new(cart, nil) }

      it 'returns failure with correct result' do
        expect(service.call).to have_attributes(success?: false, error: 'Product is not in the cart')
      end
    end
  end
end
