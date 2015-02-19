class OrderEvent < ActiveRecord::Base
  belongs_to :order
  has_one :user
end