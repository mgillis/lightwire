class AccountsController < ApplicationController

	# GET /accounts/1234
	def show

		@acc = Account.find_by_id(params[:id])

		if @acc.present?
			verify_key @acc or return false

			respond_with @acc
		else
			respond_with nil, :status => 404
		end
	end

end
