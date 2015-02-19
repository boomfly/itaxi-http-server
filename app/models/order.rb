require 'smsc_api'

class Order < ActiveRecord::Base
  belongs_to :company
  has_and_belongs_to_many :users
  has_many :events, :class_name => 'OrderEvent'
  has_many :stops, :class_name => 'OrderStop'
  has_many :route, :class_name => 'OrderRoutePoint'


  def self.create_next(user, params)
    params[:order][:number] = next_number(user.company_id)
    params[:order][:company_id] = user.company_id
    params[:order][:status] = 'new'

    # Создаем новый заказ
    order = Order.create new_order_params(params)

    # Дабвляем оператора к заказу
    order.users << user

    # Создаем остановки
    #stops = params.require(:order).permit(:stops => [:index, :latitude, :longitude, :street, :home, :flat, :order_id])
    stops = params[:order][:stops]
    stops.each do |stop|
      stop[:order_id] = order.id
      OrderStop.create new_stop_params(stop)
    end

    # Событие - заказ создан
    OrderEvent.create(
        order_id: order.id,
        event_type: 'create',
        event_date: DateTime.current,
        content: ''
    )

    # Отправить уведомление о созданном заказе
    data = order.to_json(:include => [:stops, :events, :users])
    SocketService.send_to_company(user.company_id, 'orders', {verb: 'created', data: data, user: user})

    Order.where({id: order.id}).includes(:stops, :events, :users).first
  end

  def self.update_with_nested(user, params)
    order = Order.find params[:id]

    order.update order_update_params(params)

    OrderStop.delete_all(order_id: order.id)

    stops = params[:order][:stops]
    if stops
      stops.each do |stop|
        stop[:order_id] = order.id
        OrderStop.create new_stop_params(stop)
      end
    end

    OrderEvent.create(
        order_id: order.id,
        event_date: DateTime.current,
        event_type: 'update',
        user_id: user.id)

    data = order.to_json(:include => [:stops, :events, :users])
    SocketService.send_to_company(user.company_id, 'orders', {verb: 'updated', data: data, user: user})

    order
  end

  def self.take(user, params)
    order = Order.find params[:id]
    order.set_driver user
    if order.pre
      order.update status: 'wait_for_time'
    else
      order.update status: 'drive_to_client'
    end

    OrderEvent.create(
        order_id: order.id,
        user_id: user.id,
        event_date: DateTime.current,
        event_type: 'taken')

    company = Company.find user.company_id
    if company.sms_on_order_taken?
      SMSC.new.send_sms(order.phone_number, company.sms_on_order_taken_text)
    end

    data = order.to_json(:include => [:stops, :events, :users])
    SocketService.send_to_company(user.company_id, 'orders', {verb: 'taken', data: data, user: user})

    order
  end

  def self.wait(user, params)
    order = Order.find params[:id]
    order.update status: 'waiting_client'

    OrderEvent.create(
        order_id: order.id,
        user_id: user.id,
        event_date: DateTime.current,
        event_type: 'waiting')

    company = Company.find user.company_id
    if company.sms_on_wait_for_client?
      SMSC.new.send_sms(order.phone_number, company.sms_on_wait_for_client_text)
    end

    data = order.to_json(:include => [:stops, :events, :users])
    SocketService.send_to_operators(user.company_id, 'orders', {verb: 'waiting', data: data, user: user})

    order
  end

  def self.on_the_route(user, params)
    order = Order.find params[:id]
    order.update status: 'on_the_route'

    OrderEvent.create(
        order_id: order.id,
        user_id: user.id,
        event_date: DateTime.current,
        event_type: 'on_the_route')

    data = order.to_json(:include => [:stops, :events, :users])
    SocketService.send_to_operators(user.company_id, 'orders', {verb: 'on_the_route', data: data, user: user})

    order
  end

  def self.complete(user, params)
    order = Order.find params[:id]
    order.update status: 'complete'

    OrderEvent.create(
        order_id: order.id,
        user_id: user.id,
        event_date: DateTime.current,
        event_type: 'complete')

    driver = order.get_driver
    if driver
      company = Company.find driver.company_id

      AccountTransaction.credit_company_for_order(company, order)
      AccountTransaction.credit_user_for_order(driver, order)
    end

    SocketService.send_to_operators(user.company_id, 'orders', {verb: 'completed', data: order, user: user})

    order
  end

  def self.cancel(user, params)
    order = Order.find params[:id]
    order.update status: 'cancel', cancel_reason: params[:reason]

    OrderEvent.create(
        order_id: order.id,
        user_id: user.id,
        event_date: DateTime.current,
        event_type: 'cancel')

    SocketService.send_to_company(user.company_id, 'orders', {verb: 'cancelled', data: order, user: user})
    order
  end

  def self.confirm(user, params)
    order = Order.find params[:id]
    order.update status: 'drive_to_client'

    OrderEvent.create(
        order_id: order.id,
        user_id: user.id,
        event_date: DateTime.current,
        event_type: 'confirm')

    SocketService.send_to_operators(user.company_id, 'orders', {verb: 'confirmed', data: order, user: user})
    order
  end

  def self.add_route_point(params)
    order = Order.find params[:id]
    OrderRoutePoint.create(
        order_id: order.id,
        point_date: DateTime.current,
        longitude: params[:longitude],
        latitude: params[:latitude],
    )
  end

  def get_driver
    self.users.each do |u|
      return u if u.role == 'driver'
    end
    nil
  end

  def set_driver(new_driver)
    users.delete get_driver if get_driver != nil
    users << new_driver if new_driver != nil
  end

  private

  def self.next_number(company_id)
    max = Order.where(company_id: company_id).maximum("number") || 0
    max += 1
  end

  def self.new_order_params(params)
    params.require(:order).permit(:number, :order_date, :phone_number, :status, :price, :company_id, :note, :pre)
  end

  def self.order_update_params(params)
    params.require(:order).permit(:order_date, :phone_number, :price, :note)
  end

  def self.new_event_params(params)
    params.permit(:event_date, :event_type, :content, :order_id)
  end

  def self.new_stop_params(params)
    params.permit(:index, :latitude, :longitude, :street, :home, :flat, :order_id)
  end
end

class String
  def is_integer?
    self.to_i.to_s == self
  end
end

