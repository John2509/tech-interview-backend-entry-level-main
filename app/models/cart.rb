class Cart < ApplicationRecord
  ABANDONED_THRESHOLD = 3
  REMOVE_THRESHOLD = 7

  has_many :cart_items, dependent: :destroy
  
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  before_validation :update_total_price
  
  def update_total_price
    self.reload if self.id # Check if cart is on the database before doing the reload query
    self.total_price = self.cart_items.map(&:total_price).sum()
  end

  def add_cart_item!(product, quantity)
    cart_item = self.cart_items.with_product(product).first
    if cart_item
      cart_item.update!(quantity: cart_item.quantity + quantity)
    else
      CartItem.create!(quantity: quantity, cart: self, product: product)
    end
    self.update_last_interaction
  end

  def destroy_cart_item!(product)
    cart_item = self.cart_items.with_product(product).first
    if cart_item
      cart_item.destroy!
      self.update_last_interaction
    else
      raise "Cart does not contain product #{product.id}"
    end
  end

  def mark_as_abandoned
    self.update_attribute(:abandoned, true) if (not self.abandoned?) and self.last_interaction_at <= ABANDONED_THRESHOLD.hours.ago
  end

  def remove_if_abandoned
    self.destroy if self.abandoned? and self.last_interaction_at <= REMOVE_THRESHOLD.days.ago
  end

  private
    def update_last_interaction
      self.update_attribute(:last_interaction_at, DateTime.now)
    end
end
