class PushService
  def self.send_to_user(user_id, data)
    destination = []
    UserDevice.where('user_id = ?', user_id).each do |device|
      destination << device.token
    end
    puts 'Sending push to:'
    puts destination
    puts data
    GCM.send_notification(destination, data)
  end

  def self.send_to_drivers(company_id, data)
    destination = []
    User.where('role = ? AND company_id = ?', 'driver', company_id).includes(:devices).find_each do |user|
      user.devices.each do |device|
        destination << device.token
      end
    end
    puts 'Sending push to:'
    puts destination
    puts data
    puts GCM.send_notification(destination, data)
  end

  def self.send(destination, data)
    GCM.send_notification(destination, data)
  end
end