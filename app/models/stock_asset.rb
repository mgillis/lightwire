class StockAsset < ActiveRecord::Base
  belongs_to :portfolio
  attr_accessible :symbol, :amount, :margin_rate

  def market_value
    quotes = Finance::Yahoo.last_quotes(symbol)

    if !quotes.key?(symbol)
      # ???
      return nil, nil
    end

    quote_currency, price = quotes[symbol]

    return quote_currency, price * amount
  end

  def market_value_in_currency (curr)
    mv_curr, mv_val = market_value
    return nil if mv_curr.nil?

    return Finance::Yahoo.currency_convert(mv_curr, curr, mv_val).round(2)
  end

end
