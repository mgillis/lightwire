class PortfoliosController < ApplicationController

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

	# GET /accounts/1234/portfolios/4567
	def show
		@account = Account.find_by_id(params[:account_id])

		if @account.nil?
			respond_with nil, :status => 404
		else
			@portfolio = Portfolio.find_by_id(params[:id])
			if @portfolio.account != @account
				respond_with nil, :status => 404
			else
				verify_key @portfolio.account or return false
				respond_with @portfolio
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

	# POST /accounts/:account_id/portfolios/:id/stocktrade(.:format)
	def stocktrade
		@account = Account.find_by_id(params[:account_id])

		if @account.nil?
			respond_with nil, :status => 400
		else
			@portfolio = Portfolio.find_by_id(params[:id])
			if @portfolio.account != @account
				respond_with nil, :status => 400
			else
				verify_key @portfolio.account or return false
				respond_with @portfolio.open_stock_trade(params)
			end
		end
	end

	# POST /accounts/:account_id/portfolios/:id/currencytrade(.:format)
	def currencytrade
		@account = Account.find_by_id(params[:account_id])

		if @account.nil?
			respond_with nil, :status => 400
		else
			@portfolio = Portfolio.find_by_id(params[:id])
			if @portfolio.account != @account
				respond_with nil, :status => 400
			else
				verify_key @portfolio.account or return false
				respond_with @portfolio.open_currency_trade(params)
			end
		end
	end

end
