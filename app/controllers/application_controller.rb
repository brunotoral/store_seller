class ApplicationController < ActionController::API
  before_action :set_current_cart
  before_action :create_cart, unless: :cart_found?

  private

    def current_cart
      @current_cart
    end

    def set_current_cart
      @current_cart = Cart.find_by(id: session[:cart_id])
    end

    def create_cart
      @current_cart = Cart.create(last_interaction_at: Time.current, total_price: 0)
      session[:cart_id] = @current_cart.id
    end

    def cart_found?
      @current_cart.present?
    end
end
