# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Carts::ServiceResult do
  class TestService
    include Carts::ServiceResult
  end

  let(:service) { TestService.new }

  describe '#success' do
    it 'returns a successful Result object' do
      result = service.success('test result')

      expect(result).to have_attributes(
        success?: true,
        result: 'test result',
        error: nil
      )
    end
  end

  describe '#failure' do
    it 'returns a failed Result object' do
      result = service.failure('test error')

      expect(result).to have_attributes(
        success?: false,
        result: nil,
        error: 'test error'
      )
    end
  end
end
