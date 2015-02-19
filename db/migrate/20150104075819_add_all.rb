class AddAll < ActiveRecord::Migration
  def change
    add_column :users, :company_id, :integer
    add_column :users, :role, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :balance, :float

    create_table(:companies) do |t|
      t.string :name, :null => false, :default => ''
      t.float :balance, :default => 0

      t.boolean :pay_on_refuse, :default => false
      t.float :driver_bid, :default => 0

      t.boolean :sms_on_looking_for_car, :default => false
      t.boolean :sms_on_order_taken, :default => false
      t.boolean :sms_on_wait_for_client, :default => false

      t.string :sms_on_looking_for_car_text
      t.string :sms_on_order_taken_text
      t.string :sms_on_wait_for_client_text

      t.integer :pre_order_time, :default => 60
      t.integer :pre_order_confirm_time, :default => 30

      t.integer :user_id

      t.timestamps null: false
    end

    create_table(:orders) do |t|
      t.belongs_to :company, index: true

      t.integer :number
      t.datetime :order_date
      t.datetime :close_date
      t.string :cancel_reason
      t.string :status, :null => false
      t.string :note
      t.string :phone_number, :null => false
      t.float :price, :default => 0
      t.boolean :pre, :default => false

      t.boolean :confirmation_sent, :default => false
      t.boolean :confirmed, :default => false

      t.timestamps null: false
    end

    create_table :orders_users, id: false do |t|
      t.belongs_to :order, index: true
      t.belongs_to :user, index: true
    end


    # OrderEvent
    create_table :order_events do |t|
      t.belongs_to :order, index: true
      t.integer :user_id

      t.datetime :event_date
      t.string :event_type
      t.string :content
    end


    # OrderStop
    create_table :order_stops do |t|
      t.belongs_to :order, index: true

      t.integer :index
      t.float :latitude
      t.float :longitude
      t.string :street
      t.string :home
      t.string :flat
    end

    # OrderRoutePoint
    create_table :order_route_points do |t|
      t.belongs_to :order, index: true

      t.datetime :point_date
      t.float :latitude
      t.float :longitude
    end


    # UserDevice
    create_table :user_devices do |t|
      t.belongs_to :user, index: true

      t.string :token
    end

    # AccountTransaction
    create_table :account_transactions do |t|
      t.belongs_to :user, index: true
      t.belongs_to :company, index: true

      t.datetime :transaction_date
      t.string :transaction_type
      t.string :method
      t.string :note
      t.float :amount

      t.timestamps null: false
    end

    # Chat
    create_table :chats do |t|
      t.timestamps null: false
    end

    create_table :chats_users, id: false do |t|
      t.belongs_to :chat, index: true
      t.belongs_to :user, index: true
    end

    # Message
    create_table :messages do |t|
      t.belongs_to :chat, index: true
      t.belongs_to :user, index: true

      t.string :message_type
      t.string :text
      t.string :file
      t.boolean :is_read, :default => false

      t.timestamps null: false
    end

    # Car
    create_table :cars do |t|
      t.belongs_to :user, index: true

      t.string :model
      t.string :brand
      t.string :color
      t.string :number
    end
  end
end
