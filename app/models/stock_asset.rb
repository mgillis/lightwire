class StockAsset < ActiveRecord::Base
  belongs_to :portfolio
  attr_accessible :symbol, :amount, :margin_rate

  def market_value
    quotes = Finance::Yahoo.last_quotes(symbol)

    if !quotes.key?(symbol)
      # ???
      return 0
    end

    quote_currency, price = quotes[symbol]

    return quote_currency, price * amount
  end

end
