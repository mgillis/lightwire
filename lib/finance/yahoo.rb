require 'open-uri'
require 'uri'
require 'csv'

module Finance
  module Yahoo

  	URL = 'http://download.finance.yahoo.com/d/quotes.csv'

  	# csv format; querying for symbol, name, ask, bid, currency
  	BASE_PARAMS = { 'e' => '.csv', 'f' => 'snb2b3abc4' }

  	def self.buy_quote (sym)

  	end


  	private 

  	def self.query (sym)
  		query_url = URL + '?' + URI.encode_www_form(BASE_PARAMS.merge('s' => sym))
  		CSV.new(open(query_url)).read
  	end

  end
end