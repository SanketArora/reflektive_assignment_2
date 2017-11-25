class OrderProcessor

  attr_reader :cart, :order

  def initialize(order, cart, params, session)
    @order = order
    @cart = cart
  end

  def process
    add_ordered_items_to_order
    compute_order_total
    process_payment
    save_order
  end

  def save_order
    if order.save
      post_process
      return true
    else
      return false
    end
  end

  def post_process
    Cart.destroy(session[:cart_id])
    OrderMailer.order_confirmation(order.billing_email, session[:order_id]).deliver
  end

  def process_payment
    if payment_processor.make_payment
      order.order_status = 'processed'
    else
      order.errors.add(:error, payment_processor.error)
    end
  end

  def add_ordered_items_to_order
    cart.ordered_items.each do |item|
      order.ordered_items << item
    end
  end

  def compute_order_total
    compute_ordered_items_total
    add_shipping_and_taxes_to_order_total
  end

  def compute_ordered_items_total
    order.total = order.ordered_items.inject(0) {|total, item| total + (item.quantity * item.product.price)}
  end

  def add_shipping_and_taxes_to_order_total
    case params[:order][:shipping_method]
    when 'ground'
      order.total = (order.taxed_total).round(2)
    when 'two-day'
      order.total = order.taxed_total + (15.75).round(2)
    when "overnight"
      order.total = order.taxed_total + (25).round(2)
    end
  end

  def payment_processor
    @payment_processor ||= PaymentProcessor.new(order.total, params)
  end
end
