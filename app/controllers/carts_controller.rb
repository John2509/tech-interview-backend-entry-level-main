class CartsController < ApplicationController
  before_action :set_cart, only: %i[ show ]

  # GET /cart
  def show
    render json: cart_view
  end

  # POST /cart
  def create
    @cart = session[:cart_id] ? set_cart : Cart.new

    @cart.add_cart_item(product, cart_item_quantity)

    if @cart.save
      if session[:cart_id]
        render json: cart_view
      else
        session[:cart_id] = @cart.id
        render json: cart_view, status: :created
      end
    else
      render json: @cart.errors, status: :unprocessable_entity
    end
  end

  private
    def set_cart
      @cart = Cart.find(session[:cart_id])
    end

    def cart_item_quantity
      Integer(params.require(:quantity))
    end

    def product
      Product.find(product_id)
    end

    def product_id
      params.require(:product_id)
    end

    def cart_view
      {
        id: @cart.id,
        total_price: @cart.total_price,
        products: @cart.cart_items.map{ |cart_item| {
          id: cart_item.product.id,
          quantity: cart_item.quantity,
          total_price: cart_item.total_price,
          name: cart_item.name,
          unit_price: cart_item.unit_price,
        }},
      }
    end
end
