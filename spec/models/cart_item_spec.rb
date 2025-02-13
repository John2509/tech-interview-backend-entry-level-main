# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartItem, type: :model do
  let(:cart) { Cart.create }
  let(:product) { Product.create(name: 'Test Product', price: 10.0) }

  context 'with relationships' do
    it 'should belongs to a cart' do
      t = CartItem.reflect_on_association(:cart)
      expect(t.macro).to eq(:belongs_to)
    end

    it 'should belongs to a product' do
      t = CartItem.reflect_on_association(:product)
      expect(t.macro).to eq(:belongs_to)
    end
  end

  context 'when validating' do
    it 'validates presence of quantity' do
      cart_item = described_class.new(cart: cart, product: product)
      expect(cart_item.valid?).to be_falsey
      expect(cart_item.errors[:quantity]).to include("can't be blank")
    end

    it 'validates numericality of quantity' do
      cart_item = described_class.new(cart: cart, product: product, quantity: -1)
      expect(cart_item.valid?).to be_falsey
      expect(cart_item.errors[:quantity]).to include('must be greater than or equal to 1')
    end
  end

  describe 'total_price' do
    let(:cart_item) { described_class.create(cart: cart, product: product, quantity: 2) }
    it 'should return the correct value' do
      expect(cart_item.total_price).to eq(cart_item.quantity * product.price)
    end
  end
end
