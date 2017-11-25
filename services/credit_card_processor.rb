class CreditCardProcessor

  attr_reader :card_params

  def initialize(card_params)
    @card_params = card_params || {}
  end

  def get_card
    card_type = get_card_type

    ActiveMerchant::Billing::CreditCard.new(
      number: card_params[:card_number],
      month: card_params[:card_expiration_month],
      year: card_params[:card_expiration_year],
      verification_value: card_params[:cvv],
      first_name: card_params[:card_first_name],
      last_name: card_params[:card_last_name],
      type: card_type
    )
  end

  def get_card_type
    length = card_params[:card_number].size

    if length == 15 && number =~ /^(34|37)/
      "AMEX"
    elsif length == 16 && number =~ /^6011/
      "Discover"
    elsif length == 16 && number =~ /^5[1-5]/
      "MasterCard"
    elsif (length == 13 || length == 16) && number =~ /^4/
      "Visa"
    else
      "Unknown"
    end
  end
end
