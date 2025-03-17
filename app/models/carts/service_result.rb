# frozen_string_literal: true

module Carts
  module ServiceResult
    Result = Data.define(:success?, :result, :error)

      def success(result)
        Result.new(true, result, nil)
      end

      def failure(error)
        Result.new(false, nil, error)
      end
  end
end
