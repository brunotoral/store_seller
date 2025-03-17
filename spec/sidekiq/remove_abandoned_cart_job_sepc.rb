
# frozen_String_literal: true

require 'rails_helper'

RSpec.describe RemoveAbandonedCartJob, type: :job do
  describe '#perform' do
    let!(:recent_cart) { create(:cart, status: :active, last_interaction_at: 2.hours.ago) }

    let(:new_abandoned_cart) { create(:cart, status: :abandoned, last_interaction_at: 4.hours.ago) }
    context 'when there has abandoned carts' do
    let!(:abandoned_cart) { create(:cart, status: :abandoned, last_interaction_at: 8.days.ago) }
      before do
        allow(Rails.logger).to receive(:info)
      end

      it 'marks carts with last_interaction_at older than 3 hours as abandoned' do
        expect { described_class.new.perform
        }.to change { Cart.count }.by(-1)
      end

      it 'logs the number of carts marked as abandoned' do
        described_class.new.perform

        expect(Rails.logger).to have_received(:info).with('RemoveAbandonedCartJob: Successfully destroyed 1 abandoned carts.')
      end
    end

    context 'when there does not have abandoned carts' do
      it 'does not mark carts as abandoned if none are older than 3 hours' do
        expect(Rails.logger).to receive(:info).with('RemoveAbandonedCartJob: No abandoned carts to remove found.')

        described_class.new.perform

        expect(new_abandoned_cart.reload).to be_abandoned
      end
    end
  end
end
