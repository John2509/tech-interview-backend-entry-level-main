require 'rails_helper'

RSpec.describe "/cart", type: :request do
  pending "TODO: Escreva os testes de comportamento do controller de carrinho necessários para cobrir a sua implmentação #{__FILE__}"

  #describe "GET /show" do
  #  let(:cart) { Cart.create }
  #
  #  it "renders a successful response" do
  #    allow_any_instance_of(ActionDispatch::Request).to receive(:session) { { cart_id: cart.id } }
  #    get "/cart", as: :json
  #    expect(response).to be_successful
  #  end
  #end

  describe "PUT /add_item" do
    let(:cart) { Cart.create }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }

    context 'when the product already is not in the cart' do
      subject do
        put '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
      end
      
      it 'updates the quantity of items in the cart' do
        allow_any_instance_of(ActionDispatch::Request).to receive(:session) { { cart_id: cart.id } }
        expect { subject }.to change { cart.reload.cart_items.count }.by(1)
      end
    end
    
    context 'when the product already is in the cart' do
      let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

      subject do
        put '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
        put '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
      end
      
      it 'updates the quantity of the existing item in the cart' do
        allow_any_instance_of(ActionDispatch::Request).to receive(:session) { { cart_id: cart.id } }
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end
  end
end
