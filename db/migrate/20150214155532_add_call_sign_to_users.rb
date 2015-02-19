class AddCallSignToUsers < ActiveRecord::Migration
  def change
    add_column :users, :call_sign, :string
  end
end
