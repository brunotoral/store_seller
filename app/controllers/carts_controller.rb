class CartsController < ApplicationController
  skip_before_action :create_cart, only: %i[remove_item show]

  def create
    render json: current_cart
  end

  def show
    if current_cart
      render json: current_cart
    else
      render json: { message: 'Cart not found.' }, status: :not_found
    end
  end

  def add_item
    case service = Carts::ProductAdder.new(current_cart, product, params[:quantity]).call
    in { success?: true, result: Cart }
      render json: service.result
    in { success?: false, error: String }
      render json: { message: service.error }, status: :unprocessable_entity
    end
  end

  def remove_item
    case service = Carts::ProductRemover.new(current_cart, product).call
    in { success?: true, result: Cart }
      render json: service.result
    in { success?: true, result: {} }
       session[:cart_id] = nil
       render json: { message: 'Your cart is empty.' }
    in { success?: false, error: String }
      render json: { message: service.error }, status: :unprocessable_entity
    end
  end

  private

  def service_instance
    Carts::Service.new(current_cart, product, params[:quantity])
  end

  def product
    @product = Product.find params[:product_id]
  end
end
