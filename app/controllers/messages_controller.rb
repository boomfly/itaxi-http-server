require 'rubygems'
require 'streamio-ffmpeg'

class MessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    @messages = Message.where(chat_id: params[:chat_id]).order(created_at: :desc).page(params[:page]).per(params[:per_page])
    render json: @messages
  end

  def send_message
    #params[:user_id] = current_user.id
    if params[:message].class == String
      params_hash = {message: JSON.parse(params[:message])}
      params_hash = ActionController::Parameters.new params_hash
      params_hash = new_message_params params_hash
    else
      params_hash = new_message_params(params)
    end
    params_hash[:user_id] = current_user.id
    @message = Message.create params_hash

    if @message.message_type == 'file'
      message_file = params[:file]
      tempfile = FFMPEG::Movie.new(message_file.tempfile.path)
      puts tempfile.duration
      tempfile.transcode(Rails.root.join('public', 'uploads', @message.id.to_s + '.mp3'), FFMPEG::EncodingOptions.new, {audio_codec: 'mp3'})
      #File.open(Rails.root.join('public', 'uploads', @message.id.to_s + '.mp3'), 'wb') do |file|
      #  file.write(message_file.read)
      #end
    end

    user = Chat.where('id = ?', @message.chat_id).first.users.where('id <> ?', current_user.id).first
    if user.role == 'driver'
      if @message.message_type == 'text'
        text = @message.text
      else
        text = 'Голосовое сообщение'
      end
      PushService.send_to_user(user.id, {title: 'Новое сообщение', message: text})
    else
      SocketService.send_to_user(user.id, 'messages', {verb: 'created', data: @message})
    end
    render json: @message
  end

  # Поиск чата по id собеседника
  def find_chat
    # Достанем текущего пользователя
    user = User.includes(:chats).find(current_user.id)

    # Ищем в каждом чате
    user.chats.each do |chat|
      chat.users.each do |u|
        if u.id.to_s == params[:user_id]
          @chat = chat
          return render json: @chat, :include => [:users]
        end
      end
    end

    # Создаем новый чат если такого еще нет в базе
    if !@chat
      @chat = Chat.create {}
      @chat.users << User.find(params[:user_id])
      @chat.users << current_user
    end

    render json: @chat, :include => [:users]
  end

  def audio
    params[:user_id] = current_user.id
    @message = Message.create new_message_params(params)
    render json: @messages
  end

  def mark_as_read
    Message.where('chat_id = ? AND user_id != ?', params[:chat_id], current_user.id).update_all('is_read = 1')
    render :json => {success: true}
  end

  def new_message_params(params)
    params.require(:message).permit(:text, :message_type, :user_id, :chat_id)
  end
end
