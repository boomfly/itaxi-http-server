class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :authentication_keys => [:email, :username, :phone_number]

  def confirmed?
    true
  end

  include DeviseTokenAuth::Concerns::User

  has_and_belongs_to_many :orders
  has_and_belongs_to_many :chats
  belongs_to :company
  has_many :companies
  has_many :devices, :class_name => 'UserDevice'
  has_many :transactions, :class_name => 'AccountTransaction', :foreign_key => 'user_id'
  has_one :car
end
