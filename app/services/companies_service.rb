require 'net/http'
require 'json'

class CompaniesService
  def self.create(user, params)
    params[:company][:user_id] = user.id

    company = Company.create company_params(params)

    data = company.to_json(:include => [:users])
    SocketService.send_to_user(user.id, 'company', {verb: 'created', data: data})

    company
  end

  def self.update(user, params)
    company = Company.find params[:id]

    company.update company_params(params)

    data = company.to_json(:include => [:users])
    SocketService.send_to_user(user.id, 'company', {verb: 'updated', data: data})

    company
  end

  private

  def self.company_params(params)
    params.require(:company).permit(:name,
                                    :pay_on_refuse,
                                    :driver_bid, :sms_on_looking_for_car, :sms_on_order_taken,
                                    :sms_on_wait_for_client, :sms_on_looking_for_car_text, :sms_on_order_taken_text,
                                    :sms_on_wait_for_client_text, :pre_order_time, :pre_order_confirm_time, :user_id)
  end
end