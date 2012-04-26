require 'open-uri'
require 'uri'
require 'csv'

module Finance
  module Yahoo

  	URL = 'http://download.finance.yahoo.com/d/quotes.csv'

  	# csv format
  	BASE_PARAMS = { 'e' => '.csv', 'f' => 'snb2b3abl1c4' }

  	KEY_LIST = %w[symbol name ask_realtime bid_realtime ask bid last currency]

  	# returns {sym1 => [currency, price], ...}
  	def self.last_quotes (*symlist)
      if symlist.size == 0
        raise ArgumentError, "must be 1 or more symbols in last_quotes (was 0)"
      end
  		info = self.query(*symlist)

  		if info.nil?
  			[]
  		else
  			Hash[info.map { |k,v| [k, [v['currency'], v['last'].to_f]] }]
  		end
   	end

    def self.currency_convert(from, to, amount)
      info = self.query("#{from}#{to}=X")

      if info.nil?
        nil
      else
        info.values.first['last'].to_f * amount
      end
    end

  	# returns (currency, price)
  	def self.buy_quote (sym)
  		sym = sym.upcase
  		info = self.query(sym)

  		if info.nil?
  			[nil, nil]
  		else
  			[info[sym]['currency'], info[sym]['ask'].to_f]
  		end
  	end

  	# returns (currency, price)
  	def self.sell_quote (sym)
  		sym = sym.upcase
  		info = self.query(sym)

  		if info.nil?
  			[nil, nil]
  		else
  			[info[sym]['currency'], info[sym]['bid'].to_f]
  		end
  	end

  	class CommunicationException < Exception
  	end

  	private 

  	def self.query (*symlist)
  		query_url = URL + '?' + URI.encode_www_form(BASE_PARAMS.merge('s' => symlist.join(',')))

  		begin
  			rows = CSV.new(open(query_url)).read
  		rescue Exception => e
  			Rails.logger.error "error retrieving CSV from yahoo: #{e}"
  			raise CommunicationException, e.message
  		end

  		if rows.size > symlist.size
  			raise CommunicationException, "too many rows (#{rows.size}, expected #{symlist.size} from #{symlist.inspect}) from yahoo: #{rows.inspect}"
  		end
  		
  		results = {}

  		rows.each do |r|
			# if currency is nil it doesn't exist, or if yahoo's complaining
			next if r[-1] == '' or r[-1] == 'Missing Symbols List.'

			h = Hash[KEY_LIST.zip(r)]
			h.delete_if { |k,v| v == "N/A" }

			%w[ask bid].each do |k|
				h[k] = h.delete(k + '_realtime') if h.key?(k + '_realtime')
			end

	  		if h['ask'].present? and h['bid'].present?
	  			sym = h.delete('symbol')
	  			results[sym] = h
	  		end
	  	end

	  	results
  	end

  end
end