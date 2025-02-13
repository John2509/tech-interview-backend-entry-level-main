# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'with relationships' do
    it 'should have many cart_items' do
      t = Cart.reflect_on_association(:cart_items)
      expect(t.macro).to eq(:has_many)
    end
  end

  context 'when validating' do
    it 'validates total_price with the callback' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_truthy
      expect(cart.total_price).to eq(0)
    end
  end

  describe 'update_total_price' do
    context 'when the cart has not been saved yet' do
      let(:cart) { described_class.new }

      it 'does not call reload' do
        expect(cart).to_not receive(:reload)
        cart.update_total_price
      end
    end

    context 'when the cart has some cart items' do
      let(:cart) { described_class.create }
      let(:product_1) { Product.create(name: 'Test Product', price: 10.0) }
      let(:product_2) { Product.create(name: 'Test Product', price: 5.0) }

      subject do
        CartItem.create(cart: cart, product: product_1, quantity: 2)
        CartItem.create(cart: cart, product: product_2, quantity: 1)
        cart.update_total_price
      end

      it 'update the total_price' do
        expect { subject }.to change { cart.total_price }.to(25.0)
      end
    end
  end

  describe 'add_cart_item!' do
    let(:cart) { described_class.create }
    let(:product) { Product.create(name: 'Test Product', price: 10.0) }
    let(:quantity) { 2 }

    subject do
      cart.add_cart_item!(product, quantity)
    end

    context 'when the cart does not have the product' do
      it 'updates the quantity of items in the cart' do
        expect { subject }.to change { cart.reload.cart_items.count }.by(1)
      end
    end

    context 'when the cart have the product' do
      let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: quantity) }
      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(quantity)
      end
    end
  end

  describe 'destroy_cart_item!' do
    let(:cart) { described_class.create }
    let(:product) { Product.create(name: 'Test Product', price: 10.0) }

    subject do
      cart.destroy_cart_item!(product)
    end

    context 'when the cart does have the product' do
      let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 2) }
      it 'updates the quantity of items in the cart' do
        expect { subject }.to change { cart.reload.cart_items.count }.by(-1)
      end
    end

    context 'when the cart does not have the product' do
      it 'raises an error' do
        expect { subject }.to raise_error("Cart does not contain product #{product.id}")
      end
    end
  end

  describe 'mark_as_abandoned' do
    let(:shopping_cart) { described_class.new(last_interaction_at: 3.hours.ago) }

    it 'marks the shopping cart as abandoned if inactive for a certain time' do
      expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned? }.from(false).to(true)
    end
  end

  describe 'remove_if_abandoned' do
    let(:shopping_cart) { described_class.new(last_interaction_at: 7.days.ago) }

    it 'removes the shopping cart if abandoned for a certain time' do
      shopping_cart.mark_as_abandoned
      expect { shopping_cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
    end
  end
end
