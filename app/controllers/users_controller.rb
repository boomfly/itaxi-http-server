class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    return render json: {items: []} if not params[:company_id]

    @users = User.where company_id: params[:company_id]

    render json: {items: @users}, :include => [:car, :chats]
  end

  def create
    params_hash = create_params
    params_hash[:uid] = params_hash[:provider] = params_hash[:username]
    @user = User.new params_hash
    if params[:user][:car].presence
      car_params_hash = car_params
      car_params_hash[:user_id] = @user.id
      car = Car.create car_params_hash
      car.save!
    end
    @user.save!
    render json: @user, :include => [:car]
  end

  def update
    @user = User.find params[:id]
    @user.update update_params

    if params[:user][:car].presence
      if @user.car
        car = Car.where(id: @user.car.id).first
        car.update car_params
      else
        car_params_hash = car_params
        car_params_hash[:user_id] = @user.id
        car = Car.create car_params_hash
      end
    end

    SocketService.send_to_user(current_user.id, 'users', {verb: 'updated', data: @user})

    render json: @user, :include => [:car, :chats]
  end

  def show
    @user = User.find params[:id]

    render json: @user, :include => [:car]
  end

  def destroy
    @user = User.find params[:id]
    @user.destroy
    render json: {success: true}
  end

  def contacts
    conditions = {company_id: current_user.company_id}
    if current_user.role == 'operator'
      conditions[:role] = 'driver'
    else
      conditions[:role] = 'operator'
    end

    @users = User.select(:id, :last_name, :first_name, :call_sign).where conditions

    res = []
    @users.each do |u|
      res << {id: u.id, last_name: u.last_name, first_name: u.first_name, call_sign: u.call_sign}
    end

    # Проход по всем чатам текущего пользователя
    # с поиском не причитанных сообщений
    current_user.chats.find_each do |chat|
      count = Message.where('chat_id = ? AND user_id <> ? AND is_read = 0', chat.id, current_user.id).count

      # Если есть не прочитанные сообщения
      # то надо добавить количество их отправителю
      if count > 0
        other = chat.users.where('id <> ?', current_user.id).first
        res.each do |u|
          if u[:id] == other.id
            u[:unread_messages] = count
            break
          end
        end
      end
    end

    render json: res
  end

  def manager_dashboard
    render json: {}
  end

  def current
    render :json => User.where(id: current_user.id).first, :include => [:company, :car]
  end

  def register_device
    p = register_device_params
    p[:user_id] = current_user.id
    UserDevice.create p

    render :json => {success: true}
  end

  def unregister_device
    @device = UserDevice.where('token = ?', params[:token]).first
    if @device
      @device.destroy
    end
    render :json => {success: true}
  end


  private

  def create_params
    params.require(:user).permit(:username, :last_name, :first_name, :phone_number, :call_sign, :role, :password, :password_confirmation, :company_id)
  end

  def update_params
    params.require(:user).permit(:username, :last_name, :first_name, :phone_number, :call_sign, :role, :company_id)
  end

  def car_params
    params[:user].require(:car).permit(:model, :brand, :color, :number)
  end

  def register_device_params
    params.permit(:token)
  end
end
