class ApplicationController < ActionController::Base
	def after_sign_in_path_for(resource)
    	products_path
  	end

  # Redirect after sign up
  	def after_sign_up_path_for(resource)
    	products_path
  	end
end
