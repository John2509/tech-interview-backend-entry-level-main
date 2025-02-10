class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  
  validates_presence_of :total_price
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  before_validation :update_total_price
  
  def update_total_price
    self.reload
    self.total_price = self.cart_items.map(&:total_price).sum()
  end

  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado
end
