class CurrencyAsset < ActiveRecord::Base
  belongs_to :portfolio
  attr_accessible :amount, :iso

  def market_value_in_currency (other_currency)
    symbol = "#{iso}#{other_currency}=X"

    quotes = Finance::Yahoo.last_quotes(symbol)

    if !quotes.key?(symbol)
      # ???
      return nil, nil
    end

    quote_currency, price = quotes[symbol]

    return other_currency, (price * amount).round(2)
  end
end
