class ClientsController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.where company_id: params[:company_id]

    render json: @users, :include => [:car, :chats]
  end

  def card
    phone_number = params[:phone_number]
    conditions ={
        phone_number: phone_number,
        company_id: current_user.company_id,
        status: 'complete'
    }
    @orders = Order.where(conditions).order(created_at: :desc)
    total_money = 0
    @orders.find_each do |order|
      total_money += order.price
    end
    render json: {phone_number: phone_number, total_money: total_money, total: @orders.count}
  end

  def orders_history
    phone_number = params[:phone_number]
    page = params[:page] or 1
    per_page = params[:per_page] or 10

    conditions ={
        phone_number: phone_number,
        company_id: current_user.company_id,
        status: 'complete'
    }
    @orders = Order.where(conditions).order(created_at: :desc)
    items_total = @orders.count
    @orders = @orders.page(page).per(per_page)
    render json: {items: @orders, items_total: items_total}, :include => [:stops, :events, :users]
  end
end
