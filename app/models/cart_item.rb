class CartItem < ApplicationRecord
  belongs_to :product
  belongs_to :cart

  delegate :name, to: :product
  delegate :price, to: :product, prefix: :unit
  
  validates_presence_of :quantity
  validates_numericality_of :quantity, greater_than_or_equal_to: 0

  scope :with_product, ->(product) { where(product: product) }
  
  after_save :update_cart

  def total_price
    self.product.price * self.quantity
  end

  private
    def update_cart
      self.cart.update_total_price
      self.cart.save
    end
end
