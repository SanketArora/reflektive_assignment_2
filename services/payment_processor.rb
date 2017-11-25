class PaymentProcessor

  attr_reader :params, :credit_card, :gateway, :amount_to_charge
  attr_processor :error

  def initialize(amount_to_charge, params)
    @amount_to_charge = amount_to_charge
    @params = params
    @error = {}
    load_gateway
    load_credit_card
  end

  def make_payment
    if credit_card.valid?
      options = { address: {}, billing_address: billing_address }
      response = gateway.purchase(charge_amount, credit_card, options)

      error = {err_type: "payment_failed", msg: "We couldn't process your credit card"} unless response.success?
      return response.success?
    else
      error = {err_type: "invalid_card", msg: "Your credit card seems to be invalid"}
      return false
    end
  end

  private

  def charge_amount
    (amount_to_charge * 100).to_i
  end

  def billing_address
    @billing_address ||= {
      name: "#{params[:billing_first_name]} #{params[:billing_last_name]}",
      address1: params[:billing_address_line_1],
      city: params[:billing_city],
      state: params[:billing_state],
      country: 'US',
      zip: params[:billing_zip],
      phone: params[:billing_phone]
    }
  end

  def load_gateway
    @gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new(
      login: ENV["AUTHORIZE_LOGIN"],
      password: ENV["AUTHORIZE_PASSWORD"]
    )
  end

  def load_credit_card
    credit_card_processor = CreditCardProcessor.new(params[:card_info])
    @credit_card = credit_card_processor.get_card
  end
end
