class Cart < ApplicationRecord
  ABANDONED_THRESHOLD = 3
  REMOVE_THRESHOLD = 7

  has_many :cart_items, dependent: :destroy

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  before_validation :update_total_price

  def update_total_price
    reload if id # Check if cart is on the database before doing the reload query
    self.total_price = cart_items.map(&:total_price).sum
  end

  def add_cart_item!(product, quantity)
    cart_item = cart_items.with_product(product).first
    if cart_item
      cart_item.update!(quantity: cart_item.quantity + quantity)
    else
      CartItem.create!(quantity: quantity, cart: self, product: product)
    end
    update_last_interaction
  end

  def destroy_cart_item!(product)
    cart_item = cart_items.with_product(product).first
    raise "Cart does not contain product #{product.id}" unless cart_item

    cart_item.destroy!
    update_last_interaction
  end

  def mark_as_abandoned
    return unless !abandoned? and last_interaction_at <= ABANDONED_THRESHOLD.hours.ago

    update_attribute(:abandoned,
                     true)
  end

  def remove_if_abandoned
    destroy if abandoned? and last_interaction_at <= REMOVE_THRESHOLD.days.ago
  end

  private

  def update_last_interaction
    update_attribute(:last_interaction_at, DateTime.now)
  end
end
