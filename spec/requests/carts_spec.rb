require 'rails_helper'

RSpec.describe "/carts", type: :request do
  let(:cart) { create(:shopping_cart) }
  let(:product) { create(:product, name: "Test Product", price: 10.0) }
  let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }

  before do
    cart.update!(total_price: cart.calculate_total_price)
  end

  describe 'GET /cart' do
    context 'when session already has a cart_id' do
      before do
        set_session(cart_id: cart.id)
        get cart_path
      end

      it 'returns the cart' do
        expect(parsed_body_response).to match(payload(cart))
      end
    end

    context 'when session does not have a cart_id' do
      before do
        get cart_path
      end

      it 'returns a new cart' do
        expect(parsed_body_response).not_to match(id: cart.id)
      end

      it 'sets the corret sesion cart_id' do
        expect(session[:cart_id]).not_to eq cart.id
      end
    end
  end

  describe 'DELETE /:product_id' do
    context 'when session already has a cart_id' do
      before do
        set_session(cart_id: cart.id)
        delete remove_item_cart_path(product.id), as: :json
      end

      it 'returns the cart' do
        expect(response.body).to be_empty
      end
    end

    context 'when session does not have a cart_id' do
      before do
        delete remove_item_cart_path(product.id), as: :json
      end

      it 'does not create a new cart' do
        expect { delete remove_item_cart_path(product.id), as: :json }.not_to change { Cart.count }
      end

      it 'does not save cart_id on session' do
        expect(session[:cart_id]).to be_nil
      end

      it 'returns an error message' do
        expect(parsed_body_response).to match({ error: 'The cart must exists' }.as_json)
      end

      it 'sets the corret sesion cart_id' do
        expect(session[:cart_id]).not_to eq cart.id
      end
    end

    context 'when product is not in the cart' do
      let(:new_product) { create(:product) }

      before do
        set_session(cart_id: cart.id)
        delete remove_item_cart_path(new_product.id), as: :json
      end

      it 'returns the error message' do
        expect(parsed_body_response).to match({error: "Product is not in the cart"}.as_json)
      end
    end

    context 'when there is more than one product in the cart' do
      let(:fixed_product) { create(:product) }
      let(:expected_change) { cart_item.total_price }
      let!(:fixed_cart_item) { create(:cart_item, cart: cart, product: fixed_product, quantity: 2) }

      before do
        set_session(cart_id: cart.id)
      end

      subject do
        delete remove_item_cart_path(product.id), as: :json
      end

      it 'returns the correct payload' do
        subject
        expect(parsed_body_response).to match(payload(cart.reload))
      end

      it 'destroys the item from the cart' do
        cart_items = cart.cart_items

        expect { subject }.to change { cart_items.reload.count }.by(-1)
      end

      it 'changes cart total_price attribute' do
        expect { subject }.to change { cart.reload.total_price }.by(-expected_change)
      end

      it 'changes the cart last_interaction_at attribute' do
        expect { subject }.to change { cart.reload.last_interaction_at }
      end
    end

    context 'when there is only one product in the cart' do
      before do
        set_session(cart_id: cart.id)
      end

      subject do
        delete remove_item_cart_path(product.id), as: :json
      end

      it 'destroys the cart' do
        expect { subject }.to change { Cart.count }.by(-1)
      end

      it 'removes cart_id from the session' do
        expect { subject }.to change { session[:cart_id] }.to(nil)
      end
    end
  end

  describe "POST /add_items" do
    before do
      set_session(cart_id: cart.id)
    end

    context 'when session does not have a cart_id' do
      let(:new_product) { create(:product) }

      before do
        session[:cart_id] = nil
        post add_item_cart_path, params: { product_id: new_product.id, quantity: 2 }, as: :json
      end

      it 'returns a new cart' do
        expect(parsed_body_response).not_to match(id: cart.id)
      end

      it 'sets the corret sesion cart_id' do
        expect(session[:cart_id]).not_to eq cart.id
      end
    end

    context 'when the procut is not in the cart' do
      let(:new_product) { create(:product) }

      subject do
        post add_item_cart_path, params: { product_id: new_product.id, quantity: 2 }, as: :json
      end

      it 'creates a new item in the cart' do
        cart_items = cart.cart_items

        expect { subject }.to change { cart_items.reload.count }.by(1)
      end

      it 'returns the correct payload' do
        subject
        expect(parsed_body_response).to match(payload(cart.reload))
      end
    end

    context 'when quantity is not positive' do
      before do
        post add_item_cart_path, params: { product_id: product.id, quantity: 0 }, as: :json
      end

      it 'returns correct error message' do
        expect(parsed_body_response).to match({ error: "Quantity must be a positive integer" }.as_json)
      end
    end

    context 'when the product already is in the cart' do
      subject do
        post add_item_cart_path, params: { product_id: product.id, quantity: 1 }, as: :json
        post add_item_cart_path, params: { product_id: product.id, quantity: 1 }, as: :json
      end

      before do
        post add_item_cart_path, params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end

      it 'returns the correct payload' do
        expect(parsed_body_response).to match(payload(cart.reload))
      end
    end
  end

  private

    def parsed_body_response
      JSON.parse(response.body)
    end


    def payload(cart)
      {
        id: cart.id,
        products:  products_payload(cart),
        total_price: cart.total_price
      }.as_json
    end

    def products_payload(cart)
      cart.cart_items.map do |ci|
        {
          id: ci.product_id,
          name: ci.product.name,
          quantity: ci.quantity,
          unit_price: ci.unit_purchase_price,
          total_price: ci.total_price,
        }.as_json
      end
    end
end
