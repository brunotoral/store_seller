class CartsController < ApplicationController
  skip_before_action :create_cart, only: :remove_item

  def create
    set_current_cart
    render json: payload
  end

  def show
    render json: payload
  end

  def add_item
    case result = Carts::ProductAdder.new(current_cart, product, params[:quantity]).call
    in { success?: true, result: Cart }
      render json: payload
    in { success?: false, error: String }
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end

  def remove_item
    case result = Carts::ProductRemover.new(current_cart, product).call
    in { success?: true, result: Cart }
      render json: payload
    in { success?: true, result: {} }
       session[:cart_id] = nil
    in { success?: false, error: String }
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end

  private

  def service_instance
    Carts::Service.new(current_cart, product, params[:quantity])
  end

  def product
    @product = Product.find_by id: params[:product_id]
  end

  def payload
    {
      id: current_cart.id,
      products: products_payload,
      total_price: current_cart.total_price
    }
  end

  def products_payload
    current_cart.cart_items.map do |p|
      {
        id: p.product_id,
        name: p.product.name,
        quantity: p.quantity,
        unit_price: p.unit_purchase_price,
        total_price: p.total_price,
      }
    end
  end
end
