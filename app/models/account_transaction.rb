class AccountTransaction < ActiveRecord::Base
  belongs_to :user

  def self.credit_user_for_order(user, order)
    amount = Company.find(user.company_id).driver_bid

    AccountTransaction.create(
        user_id: user.id,
        transaction_type: 'credit',
        method: 'system',
        note: 'Плата за выполненный заказ № ' + order.number.to_s,
        amount: amount
    )

    user.balance -= amount
    user.save
  end

  def self.credit_company_for_order(company, order)
    amount = order.price / 100.0 * 5.0

    AccountTransaction.create(
        company_id: company.id,
        transaction_type: 'credit',
        method: 'system',
        note: 'Плата за отработанный заказ № ' + order.number.to_s,
        amount: amount
    )

    company.balance -= amount
    company.save
  end
end