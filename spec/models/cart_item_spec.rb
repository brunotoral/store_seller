# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartItem, type: :model do
  subject { build(:cart_item, product:, cart:, quantity: 2, unit_purchase_price: product.price) }
  let(:product) { build(:product, price: 10.0) }
  let(:cart) { build(:cart) }

  describe 'associations' do
    it { is_expected.to belong_to(:cart) }
    it { is_expected.to belong_to(:product) }
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:quantity).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:unit_purchase_price).is_greater_than(0) }
  end

  describe '#total_price' do
    it 'returns the unit_purchase_price multiplied by quantity' do
      expect(subject.total_price).to eq 20.0
    end
  end
end
