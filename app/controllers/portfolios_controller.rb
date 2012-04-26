class PortfoliosController < ApplicationController

	STARTING_MONEY_CURRENCY = 'USD'
	STARTING_MONEYS = 5000.0

	# GET /accounts/1234/portfolios
	def index
		@account = Account.find_by_id(params[:account_id])

		if @account.nil?
			respond_with nil, :status => 404
		else
			verify_key @account or return false
			@portfolios = @account.portfolios
			respond_with @account, @portfolios
		end
	end

	# POST /accounts/1234/portfolios
	def create
		return unless has_params?(:name, :base_currency)

		if !CURRENCY_OK?(params[:base_currency])
			render :text => "currency '#{params[:base_currency]}' not recognized - try one of #{LIGHTWIRE_CURRENCIES.join(', ')}", :status => 400
			return
		end

		@account = Account.find_by_id(params[:account_id])

		if @account.nil?
			respond_with nil, :status => 404
		else
			verify_key @account or return false
			@portfolio = Portfolio.create!(:account => @account, :name => params[:name], :base_currency => params[:base_currency])
			@portfolio.credit_currency(params[:base_currency], Finance::Yahoo.currency_convert(STARTING_MONEY_CURRENCY, params[:base_currency], STARTING_MONEYS))
			respond_with @account, @portfolio
		end
	end

	# GET /accounts/1234/portfolios/4567
	def show
		@account = Account.find_by_id(params[:account_id])

		if @account.nil?
			respond_with nil, :status => 404
		else
			@portfolio = Portfolio.includes(:currency_assets, :stock_assets).find_by_id(params[:id])
			if @portfolio.account != @account
				respond_with nil, :status => 404
			else
				verify_key @portfolio.account or return false
				respond_with @portfolio.to_json(:methods => [:net_market_value, :total_margin], :include => [:currency_assets, :stock_assets])
			end
		end
	end

	# GET  /accounts/:account_id/portfolios/:id/history(.:format)
	def history 
		@account = Account.find_by_id(params[:account_id])

		if @account.nil?
			respond_with nil, :status => 404
		else
			@portfolio = Portfolio.find_by_id(params[:id])
			if @portfolio.account != @account
				respond_with nil, :status => 404
			else
				verify_key @portfolio.account or return false
				respond_with @portfolio.history
			end
		end
	end

	# GET  /accounts/:account_id/portfolios/:id/forex(.:format)
	def forex
		@account = Account.find_by_id(params[:account_id])

		if @account.nil?
			respond_with nil, :status => 404
		else
			@portfolio = Portfolio.find_by_id(params[:id])
			if @portfolio.account != @account
				respond_with nil, :status => 404
			else
				verify_key @portfolio.account or return false
				respond_with @portfolio.forex
			end
		end
	end

	# GET  /accounts/:account_id/portfolios/:id/securities(.:format)
	def securities
		@account = Account.find_by_id(params[:account_id])

		if @account.nil?
			respond_with nil, :status => 404
		else
			@portfolio = Portfolio.find_by_id(params[:id])
			if @portfolio.account != @account
				respond_with nil, :status => 404
			else
				verify_key @portfolio.account or return false
				respond_with @portfolio.securities
			end
		end
	end

	# POST /accounts/:account_id/portfolios/:id/stocktrade(.:format)
	# params needed: symbol, amount, tradetype
	def stocktrade
		return unless has_params?(:symbol, :amount, :tradetype)

		@account = Account.find_by_id(params[:account_id])

		if @account.nil?
			respond_with nil, :status => 400
		else
			@portfolio = Portfolio.find_by_id(params[:id])
			if @portfolio.account != @account
				respond_with nil, :status => 400
			else
				verify_key @portfolio.account or return false
				result = @portfolio.open_stock_trade(params[:symbol], params[:amount], params[:tradetype])

				if result.class == String
					respond_with result, :status => 422
				else
					respond_with result, :status => 201
				end
			end
		end
	end

	# POST /accounts/:account_id/portfolios/:id/currencytrade(.:format)
	# params needed: source, target, amount, tradetype
	def currencytrade
		return unless has_params?(:source, :target, :amount, :tradetype)

		[params[:source], params[:target]].each do |curr|
			if !CURRENCY_OK?(curr)
				respond_with :text => "currency '#{curr}' not recognized - try one of #{LIGHTWIRE_CURRENCIES.join(', ')}", :status => 400
				return
			end
		end

		@account = Account.find_by_id(params[:account_id])

		if @account.nil?
			respond_with nil, :status => 400
		else
			@portfolio = Portfolio.find_by_id(params[:id])
			if @portfolio.account != @account
				respond_with nil, :status => 400
			else
				verify_key @portfolio.account or return false
				result = @portfolio.open_currency_trade(params[:source], params[:target], params[:amount], params[:tradetype])

				if result.class == String
					respond_with result, :status => 422
				else
					respond_with result, :status => 201
				end
			end
		end
	end

end
