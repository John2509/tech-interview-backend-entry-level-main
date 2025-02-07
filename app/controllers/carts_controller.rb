class CartsController < ApplicationController
  # GET /cart
  def show
    @cart = Cart.last
    render json: @cart
  end

  # POST /cart
  def create
    @cart = Cart.new(total_price: 0)

    if @cart.save
      render json: @cart, status: :created, location: @cart
    else
      render json: @cart.errors, status: :unprocessable_entity
    end
  end
end
