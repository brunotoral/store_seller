module Test
  class SessionsController < ApplicationController
    def create
      vars = params.permit(session_vars: {})
      vars[:session_vars].each do |var, value|
        session[var] = value
      end
      head :created
    end
  end

  module RequestSessionHelper
    def set_session(vars = {})
      post test_session_path, params: { session_vars: vars }
      expect(response).to have_http_status(:created)

      vars.each_key do |var|
        expect(session[var]).to be_present
      end
    end
  end
end

RSpec.configure do |config|
  config.include Test::RequestSessionHelper

  config.before(:all, type: :request) do
    Rails.application.routes.send(:eval_block, Proc.new do
      namespace :test do
        resource :session, only: %i[create]
      end
    end)
  end
end
