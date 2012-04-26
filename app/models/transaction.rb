class Transaction < ActiveRecord::Base
  belongs_to :portfolio
  has_one :account, :through => :portfolio
  belongs_to :action
  belongs_to :status, :class_name => "TransactionStatus", :foreign_key => 'transaction_status_id'

  VALID_FOR_SECONDS = 30

  attr_accessible :cost, :count, :currency, :fee, :target, :time_opened, :time_closed, :action, :status, :portfolio

  class ExpiredException < Exception
  end

  def execute
    transaction do
      if status != TransactionStatus.OPEN
        raise ActiveRecord::ReadOnlyRecord
      end

      if time_opened <= Time.now.utc - VALID_FOR_SECONDS
        status = TransactionStatus.CANCELLED
        time_closed = Time.now.utc
        save!
        raise ExpiredException
      end

      # do it
      if action == Action.SELL_STOCK
        portfolio.has_stock?(target, count) or portfolio.has_margin?(currency, cost) or return false
        
        portfolio.debit_stock(target, count, currency)
        portfolio.credit_currency(currency, cost - fee)
      elsif action == Action.BUY_STOCK
        portfolio.has_currency?(currency, cost + fee) or portfolio.has_margin?(currency, cost) or return false
        
        portfolio.debit_currency(currency, cost + fee)
        portfolio.credit_stock(target, count, currency)
      elsif action == Action.SELL_CURRENCY
        portfolio.has_currency?(target, cost) or portfolio.has_margin?(target, cost) or return false

        portfolio.debit_currency(target, cost)
        portfolio.credit_currency(currency, count - fee)
      elsif action == Action.BUY_CURRENCY
        portfolio.has_currency?(currency, cost + fee) or portfolio.has_margin?(currency, cost) or return false

        portfolio.debit_currency(currency, cost + fee)
        portfolio.credit_currency(target, count)
      else
        raise ArgumentError, "unrecognized action (#{action.id}: #{action.name}) in transaction.execute"
      end

      self.status = TransactionStatus.COMPLETE
      self.time_closed = Time.now.utc
      self.save!
      return true
    end
  end

  def cancel
    transaction do
      if status == TransactionStatus.CANCELLED
        return true
      end

      if status != TransactionStatus.OPEN
        raise ActiveRecord::ReadOnlyRecord
      end

      self.status = TransactionStatus.CANCELLED
      self.time_closed = Time.now.utc
      self.save!
      return true
    end
  end

  def set_fee
  	if status != TransactionStatus.OPEN
  		raise ActiveRecord::ReadOnlyRecord, "transaction status is #{status.inspect}"
  	end

  	# symbol = "#{target}#{source}=X"

  	if target.ends_with?('=X')
  		# currency
  		f = cost*0.00002
      if currency != "USD"
  		  min = Finance::Yahoo.convert_currency("USD", currency, 2.50)
      else
        min = 2.50
      end
  		f = min if f < min
  		self.fee = f

  	else
  		# security

  		case currency
  		when 'USD'
  			if count > 500
  				f = count.to_f*0.008
  			else
  				f = count.to_f*0.013
  			end
  			f = cost*0.005 if f > cost*0.005
  			f = 1.3 if f < 1.3
  			self.fee = f
  		when 'CAD'
  			self.fee = simple_fee(count.to_f*0.01, 1, cost*0.005)
  		when 'EUR'
  			self.fee = simple_fee(cost*0.001, 4, 29)
  		when 'GBP'
  			f = 6
  			over_50k = count - 50000
  			if over_50k > 0
  				f += 0.0005 * over_50k.to_f
  				f = 29 if f > 29
  			end
  			self.fee = f
  		when 'HKD'
  			self.fee = simple_fee(cost*0.088, 18, nil)
  		when 'AUD'
  			self.fee = simple_fee(cost*0.08, 6, nil)
  		when 'JPY'
  			self.fee = simple_fee(cost*0.08, 450, nil)
  		when 'SGD'
  			self.fee = simple_fee(cost*0.1, 3, nil)
  		else
  			raise ArgumentError, "unknown currency in fee calculation"
  		end
  	end

  	self.fee = self.fee.round(2)
  end

  private

  def simple_fee (rate, min, max)
  	simple = rate
  	simple = max if max.present? and rate > max
  	simple = min if rate < min
  	return simple
  end

end
