require 'net/http'
require 'json'

class SocketService
  def self.send_to_user(user_id, channel, data)
    FayeRails::Controller.publish "/user/#{user_id}/#{channel}", data
    return
    # payload = { 'user' => user.id, 'event' => event, 'message' => message.to_json, 'room' => 'user' }
    payload = { user: user_id, event: event, message: data.to_json, room: 'user' }
    send(payload)
  end

  def self.send_to_company(company_id, channel, data)
    FayeRails::Controller.publish "/company/#{company_id}/#{channel}", data
    return
    payload = { company: company_id, event: event, message: data.to_json, room: 'company' }
    send(payload)
  end

  def self.send_to_operators(company_id, channel, data)
    FayeRails::Controller.publish "/company/#{company_id}/operators/#{channel}", data
    return

    payload = { company: company_id, event: event, message: data.to_json, room: 'operators' }
    send(payload)
  end

  private

  def self.send(payload)
    Net::HTTP.post_form(URI.parse('http://localhost:8080/send'), payload)
  end
end