# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cart, type: :model do
  let(:shopping_cart) { create(:shopping_cart, last_interaction_at:) }
  let(:last_interaction_at) { 2.hours.ago }

  describe 'associations' do
    it { is_expected.to have_many(:cart_items).dependent(:destroy) }
    it { is_expected.to have_many(:products).through(:cart_items) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:last_interaction_at) }
    it { is_expected.to validate_numericality_of(:total_price).is_greater_than_or_equal_to(0) }
  end

  describe '#calculate_total_price' do
    let(:product) { create(:product, price: 10.0) }
    let(:product_two) { create(:product, price: 20.0) }

    before do
      create(:cart_item, cart: shopping_cart, product:, quantity: 1)
      create(:cart_item, cart: shopping_cart, product: product_two, quantity: 2  )
    end

    it 'returns the sum of the total value from all cart items' do
      expect(shopping_cart.calculate_total_price).to eq 50.0
    end
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(%i[active abandoned finished]) }
  end

  describe '#abandoned?' do
    let(:shopping_cart) { create(:shopping_cart) }

    it 'returns false if the cart is not abandoned' do
      shopping_cart.mark_as_abandoned

      expect(shopping_cart).not_to be_abandoned
    end

    it 'returns true if the cart is abandoned' do
      shopping_cart.update(last_interaction_at: 3.hours.ago)
      shopping_cart.mark_as_abandoned

      expect(shopping_cart).to be_abandoned
    end
  end

  describe '#mark_as_abandoned' do
    let(:last_interaction_at) { 3.hours.ago }

    it 'marks the shopping cart as abandoned if inactive for a certain time' do
      expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned? }.from(false).to(true)
    end
  end

  describe '#remove_if_abandoned' do
    let(:last_interaction_at) { 7.days.ago }

    it 'removes the shopping cart if abandoned for a certain time' do
      shopping_cart.mark_as_abandoned

      expect { shopping_cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
    end
  end
end
