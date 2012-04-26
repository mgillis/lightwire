class TransactionsController < ApplicationController

  # POST /transactions/:id/execute(.:format)
  def execute

    @txn = Transaction.find_by_id(params[:id])

    if @txn.present?
      verify_key @txn.account or return false
      @txn.execute
      respond_with @txn
    else
      respond_with nil, :status => 400
    end

  end

  # POST /transactions/:id/cancel(.:format)
  def cancel
    @txn = Transaction.find_by_id(params[:id])

    if @txn.present?
      verify_key @txn.account or return false
      @txn.cancel
      respond_with @txn
    else
      respond_with nil, :status => 400
    end
  end

  # GET  /accounts/:account_id/portfolios/:portfolio_id/transactions(.:format)
  def index
    @account = Account.find_by_id(params[:account_id])

    if @account.nil?
      respond_with [], :status => 404
    else
      @portfolio = Portfolio.find_by_id(params[:id])
      if @portfolio.account != @account
        respond_with [], :status => 404
      else
        verify_key @portfolio.account or return false
        respond_with @portfolio.transactions
      end
    end
  end

  # GET  /transactions/:id(.:format)
  def show
    @txn = Transaction.find_by_id(params[:id])

    if @txn.present?
      verify_key @txn.account or return false

      respond_with @txn
    else
      respond_with nil, :status => 404
    end
  end

end
