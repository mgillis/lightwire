class ApplicationController < ActionController::Base
  protect_from_forgery

  respond_to :json

	before_filter :default_format

	# rails doesn't actually have a way to do this in a better way. cool
	def default_format
	  request.format = "json"
	end

	def verify_key (account)
		if params[:key] == account.api_key
			return true
		else
			render :nothing => true, :status => 403
			return false
		end
	end

	def has_params? (*list)
		list.each do |k|
			if !params.key?(k)
				render :text => "missing required parameter '#{k}' in request", :status => 400
				return false
			end
		end
		return true
	end

end
