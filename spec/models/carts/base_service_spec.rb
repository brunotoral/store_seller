# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Carts::BaseService do
  let(:cart) { create(:cart) }
  let(:product) { create(:product) }

  class Service < Carts::BaseService
    def call
      super
    end
  end

  let(:service) { Service.new(cart, product) }

  describe '#call' do
    it 'raises NotImplementedError' do
      expect { service.call }.to raise_error(NotImplementedError, 'This method sould be implemented')
    end
  end
end
