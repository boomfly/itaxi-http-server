class OrdersController < ApplicationController
  before_action :authenticate_user!

  def send_message
    SocketService.send_to_company(1, 'orders', {verb: 'created', data: {number: '001'}})
    render json: {}
  end

  def index
    company_id = current_user.company_id

    # По умолчанию выдавать заказы компании к которой привязан текущий пользователь
    conditions = {company_id: company_id, pre: false}

    case params[:status]
      when 'new'
        @orders = Order.where('status = "new" and pre = 0')
      when 'current'
        @orders = Order.where('status = "new"')
      when 'work'
        @orders = Order.where('status in (?) and pre = 0', ['drive_to_client', 'waiting_client', 'on_the_route'])
      when 'pre'
        @orders = Order.where('status not in (?) and pre = 1', ['complete', 'cancel'])

      else
        conditions[:status] = params[:status]
    end

    @orders.includes(:users, :stops, :events)

    render json: @orders, :include => [:users, :events, :stops]
  end

  def my_orders
    @orders = current_user.orders.where.not(status: ['complete', 'cancel'])
    render json: @orders, :include => [:stops]
  end

  def create
    @order = Order.create_next(current_user, params)

    PushService.send_to_drivers(current_user.company_id, {title: 'Новый заказ', message: 'поступил новый заказ'})

    render :json => @order, :include => [:users, :events, :stops]
  end

  def update
    @order = Order.update_with_nested(current_user, params)

    render :json => @order, :include => [:users, :events, :stops]
  end

  def show
    @order = Order.find(params[:id])

    render :json => @order, :include => [:users, :events, :stops]
  end

  def take
    Order.take(current_user, params)

    render :json => {success: true}
  end

  def wait
    Order.wait(current_user, params)

    render :json => {success: true}
  end

  def on_the_route
    Order.on_the_route(current_user, params)

    render :json => {success: true}
  end

  def cancel
    Order.cancel(current_user, params)

    render :json => {success: true}
  end

  def complete
    Order.complete(current_user, params)

    render :json => {success: true}
  end
end
