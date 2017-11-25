class OrdersController < ApplicationController
  before_action :get_cart

  # process order
  def create
    @order = Order.new(order_params)

    order_processor = OrderProcessor.new(@order, @cart, params, session)

    if order_processor.process
      flash[:success] = "You successfully ordered!"
      redirect_to confirmation_orders_path
    else
      flash[:error] = "There was a problem processing your order. Please try again."
      render :new
    end
  end

  def order_params
    params.require(:order).permit!
  end

  def get_cart
    @cart = Cart.find(session[:cart_id])
  rescue ActiveRecord::RecordNotFound
  end
end
