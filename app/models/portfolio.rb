require 'set'

class Portfolio < ActiveRecord::Base
  belongs_to :account
  has_many :stock_assets
  has_many :currency_assets
  has_many :transactions
  attr_accessible :name, :account, :base_currency

  MARGIN_RATE = 0.5
  HISTORY_SIZE = 20

  def has_stock? (symbol, amount)
    s = stock_assets.where(:symbol => symbol).first
    s.present? and s.amount >= amount
  end

  def has_currency? (currency, amount)
    c = currency_assets.where(:iso => currency).first
    c.present? and c.amount >= amount
  end

  def has_margin? (currency, amount)
    if currency == base_currency
      has_base_currency_margin?(amount)
    else
      has_base_currency_margin?(Finance::Yahoo.currency_convert(currency, base_currency, amount))
    end
  end

  def has_base_currency_margin? (extra_amount)
    # your real NMV must be 50% or more of total NMV

    # idk if this is even right but whatever

    ignore, nmv_amount    = net_market_value
    ignore, margin_amount = total_margin

    raise Exception, "margin_amount is nil" if margin_amount.nil?
    raise Exception, "nmv_amount is nil" if nmv_amount.nil?
    
    (nmv_amount - margin_amount) >= ( (nmv_amount + extra_amount) * MARGIN_RATE)
  end

  def total_margin
    total = 0.0

    # collect relevant currencies
    currencies = Set.new(currency_assets.map(&:iso) + stock_assets.map(&:currency))
    return [base_currency, 0.0] if currencies.empty?

    currencies.delete( base_currency )

    if currencies.any?
      currency_symbols = currencies.map{ |c| "#{c}#{base_currency}=X"}
      quotes = Finance::Yahoo.last_quotes(*currency_symbols)
    end

    currency_values = {}
    currencies.each do |c|
      currency_values[c] = quotes["#{c}#{base_currency}=X"][1]
    end
    currency_values[base_currency] = 1.0

    short_currency = currency_assets.where('amount < 0.0')
    short_currency.each do |c|
      if c.amount < 0
        total += -c.amount * currency_values[c.iso]
      end
    end

    stocks = Hash[stock_assets.where('amount < 0.0').map{ |sa| [sa.symbol, sa] }]
    if stocks.any?
      quotes = Finance::Yahoo.last_quotes(*stocks.keys)
      quotes.each do |sym, q|
        puts "#{sym} #{q.inspect}"
        total += -stocks[sym].amount * q[1] * currency_values[q[0]]
      end
    end

    return base_currency, total.round(2)
  end

  def max_margin
    ignore, nmv_amount    = net_market_value
    
    (nmv_amount * (1.0 - MARGIN_RATE)).round(2)
  end

  def buying_power
    (nmv_amount * (1.0 + (1.0-MARGIN_RATE))).round(2)
  end

  def margin_call?
    !has_base_currency_margin?(0.0)
  end

  def cash
    base_asset = currency_assets.where(:iso => base_currency).first
    return base_currency, base_asset.present? ? base_asset.amount : 0.0
  end

  def debit_stock (symbol, amount, currency)
    credit_stock(symbol, -amount, currency)
  end

  def credit_stock (symbol, amount, currency)
    a = stock_assets.where(:symbol => symbol).first

    if a.present?
      a.amount += amount
      if a.amount == 0
        a.delete!
      else
        a.save!
      end
      save!
    else
      a = StockAsset.new()
      a.currency = currency
      a.symbol   = symbol
      a.amount   = amount
      stock_assets << a
      save!
      a.save!
    end
  end

  def debit_currency (currency, amount)
    credit_currency(currency, -amount)
  end

  def credit_currency (currency, amount)
    a = currency_assets.where(:iso => currency).first

    if a.present?
      a.amount += amount
      if a.amount == 0
        a.delete!
      else
        a.save!
      end
      save!
    else
      a = CurrencyAsset.new()
      a.iso     = currency
      a.amount  = amount
      currency_assets << a
      save!
      a.save!
    end
  end

  def net_market_value
    total = 0.0

    # collect relevant currencies
    currencies = Set.new(currency_assets.map(&:iso) + stock_assets.map(&:currency))
    return [base_currency, 0.0] if currencies.empty?

    currencies.delete( base_currency )

    if currencies.any?
      currency_symbols = currencies.map{ |c| "#{c}#{base_currency}=X"}
      quotes = Finance::Yahoo.last_quotes(*currency_symbols)
    end

    currency_values = {}
    currencies.each do |c|
      currency_values[c] = quotes["#{c}#{base_currency}=X"][1]
    end
    currency_values[base_currency] = 1.0

    currency_assets.each do |c|
      total += c.amount * currency_values[c.iso]
    end

    stocks = Hash[stock_assets.map{ |sa| [sa.symbol, sa] }]

    puts "#{stocks.inspect}"
    if stocks.any?
      quotes = Finance::Yahoo.last_quotes(*stocks.keys)
      quotes.each do |sym, q|
        puts "#{sym} #{q.inspect}"
        total += stocks[sym].amount * q[1] * currency_values[q[0]]
      end
    end

    return base_currency, total.round(2)
  end

  def open_stock_trade (symbol, amount, tradetype)
  	# params needed: symbol, amount, tradetype

  	begin
	  	if tradetype == 'buy'
	  		currency, price = Finance::Yahoo.buy_quote(symbol)
	  	elsif tradetype == 'sell'
	  		currency, price = Finance::Yahoo.sell_quote(symbol)
	  	else
	  		return "unknown tradetype '#{tradetype}'"
	  	end
  	rescue Finance::Yahoo.CommunicationException => e
  		return e.message
  	end

  	return "nothing found for symbol '#{symbol}" unless currency.present? and price.present?

    return "unsupported currency #{currency} for trading #{symbol}" if !CURRENCY_OK?(currency)

  	txn = Transaction.new(
  		:cost => (price.to_f * amount.to_f).round(2),
  		:count => amount.to_i,
  		:currency => currency,
  		:target => symbol,
  		:time_opened => Time.now.utc,
  		:action => Action.find_by_name(tradetype + "_stock"),
  		:status => TransactionStatus.OPEN,
  		:portfolio => self
  	)
  	txn.set_fee
  	txn.save!
  	txn
  end

  def open_currency_trade (source, target, amount, tradetype)
  	# params needed: source, target, amount, tradetype

  	return "invalid currency '#{source}'" unless source.length == 3
  	return "invalid currency '#{target}'" unless target.length == 3

    return "unsupported currency #{source}" if !CURRENCY_OK?(source)
    return "unsupported currency #{target}" if !CURRENCY_OK?(target)

  	symbol = "#{target}#{source}=X"

  	begin
	  	if tradetype == 'buy'
	  		ignore_currency, price = Finance::Yahoo.buy_quote(symbol)
	  	else
	  		ignore_currency, price = Finance::Yahoo.sell_quote(symbol)
	  	end
	rescue Finance::Yahoo.CommunicationException => e
		return e.message
	end

  	return "nothing found for currency pair #{source} and #{target}" unless price.present?

  	txn = Transaction.new(
  		:cost => (price.to_f * amount.to_f).round(2),
  		:count => amount.to_i,
  		:currency => source,
  		:target => symbol,
  		:time_opened => Time.now.utc,
  		:action => Action.find_by_name(tradetype + "_currency"),
  		:status => TransactionStatus.OPEN,
  		:portfolio => self
  	)
  	txn.set_fee
  	txn.save!
  	txn
  end

  def history
    transactions.where('time_closed is not null').order('time_closed desc').limit(20)
  end

  def forex
    currency_assets.map do |c|
      {
        :iso => c.iso,
        :amount => c.amount,
        :market_value  => c.market_value_in_currency(base_currency)
      }
    end
  end

  def securities
    stock_assets.map do |s|
      {
        :symbol => s.symbol,
        :amount => s.amount,
        :market_value  => s.market_value_in_currency(base_currency)
      }
    end
  end
end
