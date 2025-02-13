# frozen_string_literal: true

class CartItem < ApplicationRecord
  belongs_to :product
  belongs_to :cart

  delegate :name, to: :product
  delegate :price, to: :product, prefix: :unit

  validates :quantity, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 1 }

  scope :with_product, ->(product) { where(product: product) }

  after_save :update_cart
  after_destroy :update_cart

  def total_price
    product.price * quantity
  end

  private

  def update_cart
    cart.update_total_price
    cart.save
  end
end
