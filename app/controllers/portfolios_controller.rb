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

	# POST /accounts/1234/portfolios
	def create
		return unless has_params?(:name, :base_currency)

		@account = Account.find_by_id(params[:account_id])

		if @account.nil?
			respond_with nil, :status => 404
		else
			verify_key @account or return false
			@portfolio = Portfolio.create!(:account => @account, :name => params[:name], :base_currency => params[:base_currency])
			respond_with @portfolio
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
				respond_with @portfolio.open_stock_trade(params[:symbol], params[:amount], params[:tradetype])
			end
		end
	end

	# POST /accounts/:account_id/portfolios/:id/currencytrade(.:format)
	# params needed: source, target, amount, tradetype
	def currencytrade
		return unless has_params?(:source, :target, :amount, :tradetype)

		@account = Account.find_by_id(params[:account_id])

		if @account.nil?
			respond_with nil, :status => 400
		else
			@portfolio = Portfolio.find_by_id(params[:id])
			if @portfolio.account != @account
				respond_with nil, :status => 400
			else
				verify_key @portfolio.account or return false
				respond_with @portfolio.open_currency_trade(params[:source], params[:target], params[:amount], params[:tradetype])
			end
		end
	end

end
