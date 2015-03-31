require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
    fixtures :products

test "buying a product" do
    LineItem.delete_all
    Order.delete_all
    ruby_book = products(:ruby)

    #Пользователь заходит на страницу каталога магазина
    get "/"
    assert_response :success
    assert_template "index"

    #Он выбирает товар, добавляя его в свою корзину
    xml_http_request :post, '/line_items', product_id: ruby_book.id
    assert_response :success
    cart = Cart.find(session[:cart_id])
    assert_equal 1, cart.line_items.size
    assert_equal ruby_book, cart.line_items[0].product

    #Затем он оформляет заказ
    get "/orders/new"
    assert_response :success
    assert_template "new"

    #заполняет заявку и отправляет данные
    post_via_redirect "/orders",
                      order: { name:"Dave Thomas",
                              address:"123 The Street",
                      email: "dave@example.com",
                      pay_type: "check"}
    assert_response :success
    assert_template "index"
    cart = Cart.find(session[:cart_id])
    assert_equal 0, cart.line_items.size

    #заходим в базу данных и проверяем создали ли мы заказ и соответсвующу товарную позицию и верные ли в них данные
    orders = Order.all
    assert_equal 1, orders.size
    order = orders[0]
    assert_equal "Dave Thomas", order.name
    assert_equal "123 Street", order.address
    assert_equal "dave@example", order.email
    assert_equal "Check", order.pay_type

    assert_equal 1, order.line_items.size
    line_item = order.line_items[0]
    assert_equal ruby_book, line_item.product

    #проверяем, что само почтовое отправление правильно адресовано и имеет ожидаемую нами строку темы
    mail = ActionMailer::Base.deliveries.last
    assert_equal ["dave@example.com"], mail.to
    assert_equal 'Sam Ruby <depot@example.com>', mail[:from].value
    assert_equal "Pragmatic Store Order Confirmation", mail.subject
  end
end
