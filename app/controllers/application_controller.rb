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

  def show_order
    order_item_ids = @order.line_items.ids
    order_item_ids.each do |order_item_id|
      @show_order ||= Product.joins("INNER JOIN line_items ON line_items.product_id = products.id").where("line_items.id = #{order_item_id}").map {|product| { product:product } }

  puts "Show_Order: #{@show_order}"
  puts "Show_Order[0]: #{@show_order[0][:product].name}"
  # puts "Show_Order: #{@show_order[1][:product].name}"

    end
  end
  helper_method :show_order

end
