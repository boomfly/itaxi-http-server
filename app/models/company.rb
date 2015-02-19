class Company < ActiveRecord::Base
  belongs_to :user
  has_many :orders, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :transactions, :class_name => 'AccountTransaction', :foreign_key => 'company_id', dependent: :destroy
end