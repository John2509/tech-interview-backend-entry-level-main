require 'rails_helper'

RSpec.describe '/cart', type: :request do
  let(:product) { Product.create(name: 'Test Product', price: 10.0) }
  context 'when creating a new cart' do
    subject do
      post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
    end

    it 'renders a successful response and create a new cart' do
      expect { subject }.to change { Cart.count }.by(1)
      expect(response).to be_successful
    end
  end

  context 'when creating cart when there is already one in session' do
    subject do
      post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
      post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
    end

    it 'renders a successful response and only create one cart' do
      expect { subject }.to change { Cart.count }.by(1)
      expect(response).to be_successful
    end
  end

  context 'when showing a cart in session' do
    let(:quantity) { 2 }
    subject do
      post '/cart', params: { product_id: product.id, quantity: quantity }, as: :json
      get '/cart', as: :json
    end

    it 'renders a successful response and in the correct format' do
      subject
      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body['id']).to eq(session[:cart_id])
      expect(body['total_price']).to eq((product.price * quantity).to_s)
      expected_products = [
        {
          'id' => product.id,
          'quantity' => quantity,
          'total_price' => (product.price * quantity).to_s,
          'name' => product.name,
          'unit_price' => product.price.to_s
        }
      ]
      expect(body['products']).to match_array(expected_products)
    end
  end

  context 'when adding items to a cart' do
    context 'when the product is not on the cart' do
      let(:product_2) { Product.create(name: 'Test Product 2', price: 20.0) }

      subject do
        post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_item', params: { product_id: product_2.id, quantity: 1 }, as: :json
      end

      it 'renders a successful response and updates the quantity of items in the cart' do
        expect { subject }.to change { CartItem.count }.by(2)
        expect(response).to be_successful
      end
    end

    context 'when the product already is in the cart' do
      subject do
        post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'renders a successful response and updates the quantity of the existing item in the cart' do
        expect { subject }.to change { CartItem.count }.by(1)
        expect(response).to be_successful
        cart = Cart.find(session[:cart_id])
        expect(cart.cart_items.first.quantity).to be(3)
      end
    end
  end

  context 'when removing items from a cart' do
    context 'when the item is in the cart' do
      subject do
        post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
        delete "/cart/#{product.id}", as: :json
      end

      it 'renders a successful response and remove the cart_item' do
        expect { subject }.not_to(change { CartItem.count })
        expect(response).to be_successful
      end
    end

    context 'when the item is not in the cart' do
      let(:product_2) { Product.create(name: 'Test Product 2', price: 20.0) }

      subject do
        post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
        delete "/cart/#{product_2.id}", as: :json
      end

      it 'renders a successful response and remove the cart_item' do
        subject
        expect(response).not_to be_successful
        expect(JSON.parse(response.body)['error']).to eq("Cart does not contain product #{product_2.id}")
      end
    end
  end
end
