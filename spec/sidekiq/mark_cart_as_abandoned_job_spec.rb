# frozen_String_literal: true

require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  describe '#perform' do
    let!(:abandoned_cart) { create(:cart, status: :abandoned, last_interaction_at: 4.hours.ago) }
    let!(:recent_cart) { create(:cart, status: :active, last_interaction_at: 2.hours.ago) }

    let(:active_cart) { create(:cart, status: :active, last_interaction_at: 4.hours.ago) }
    context 'when there has abandoned carts' do
      before do
        allow(Rails.logger).to receive(:info)
        active_cart.update!(last_interaction_at: 4.hour.ago, status: :active)
      end

      it 'marks carts with last_interaction_at older than 3 hours as abandoned' do
        expect { described_class.new.perform
        }.to change { active_cart.reload.status }.from('active').to('abandoned')
      end

      it 'logs the number of carts marked as abandoned' do
        described_class.new.perform

        expect(Rails.logger).to have_received(:info).with("MarkCartAsAbandonedJob: Successfully marked 1 carts as abandoned.")
      end
    end

    context 'when there does not have abandoned carts' do
      before do
        active_cart.update!(last_interaction_at: 1.hour.ago)
      end

      it 'does not mark carts as abandoned if none are older than 3 hours' do
        expect(Rails.logger).to receive(:info).with("MarkCartAsAbandonedJob: No abandoned carts found.")

        described_class.new.perform

        expect(active_cart.reload).to be_active
      end
    end
  end
end
