class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def authorize
    redirect_to '/login' unless current_user
  end

  def cart
    @cart ||= cookies[:cart].present? ? JSON.parse(cookies[:cart]) : {}
  end
  helper_method :cart

  def enhanced_cart
    @enhanced_cart ||= Product.where(id: cart.keys).map {|product| { product:product, quantity: cart[product.id.to_s] } }
  end
  helper_method :enhanced_cart

  def cart_subtotal_cents
    enhanced_cart.map {|entry| entry[:product].price_cents * entry[:quantity]}.sum
  end
  helper_method :cart_subtotal_cents

  def update_cart(new_cart)
    cookies[:cart] = {
      value: JSON.generate(new_cart),
      expires: 10.days.from_now
    }
    cookies[:cart]
  end

  def order_price_quantity_details
    @order_price_quantity_details = Array.new
    line_item_details = LineItem.joins("INNER JOIN orders ON orders.id = line_items.order_id").where("orders.id = #{params[:id]}").map {|line_item| { line_item:line_item } }
    @order_price_quantity_details.push(line_item_details)
    return @order_price_quantity_details
  end
  helper_method :order_price_quantity_details

  def order_product_details
    @order_product_details = Array.new
    @order.line_items.ids.each do |order_item_id|
      order_item = LineItem.joins(:product)
      .select("products.name, products.description, products.image, line_items.quantity, line_items.item_price_cents, line_items.total_price_cents")
      .where("line_items.id = #{order_item_id}")
      .map {|product, line_item| { product:product, line_item:line_item } }
      @order_product_details.push(order_item)
    end
    # @order_product_details.push(order_price_quantity_details)
    puts "@@@ORDER DETAILS: #{@order_product_details}"
    return @order_product_details
  end
  helper_method :order_product_details

end
