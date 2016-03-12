class LoginController < ApplicationController
	def mobileAuth
		username = params[:username]
		password = params[:password]

		if username.to_s == "" && password.to_s == ""
			flag = nil
		else
			flag = false
			if username == "avdhut.vaidya" && password == "123456"
				flag = true
			end
		end

		render :json => flag.to_s
	end
end
