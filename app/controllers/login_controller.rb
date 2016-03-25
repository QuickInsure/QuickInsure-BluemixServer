require 'net/http'
require 'json'

class LoginController < ApplicationController
	before_filter :iciciTokenInitialize
	
	def iciciTokenInitialize
		#ICICI authentication params
		$client_id = "avdhut.vaidya@gmail.com"
		client_password = "ICIC8058"

		reqParams = {:client_id => $client_id.to_s, :password => client_password.to_s}
		requestStr = URI.parse("http://corporate_bank.mybluemix.net/corporate_banking/mybank/authenticate_client?#{reqParams.to_query}")
		response = Net::HTTP.get(requestStr)
		puts response
		$token = JSON.parse(response)[0]["token"]
	end

    #Function to validate credentials
    def validateCredentials(str)
        canAuthenticate = true
        clientId,token,accNo,custid,days = ""

        if str.split("+").length == 3
            clientId,token,accNo = str.split("+")[0],str.split("+")[1],str.split("+")[2]
        elsif str.split("+").length == 4 && type == "number"
            clientId,token,accNo,custid = str.split("+")[0],str.split("+")[1],str.split("+")[2],str.split("+")[3]
        elsif str.split("+").length == 4 && type == "days"
            clientId,token,accNo,days = str.split("+")[0],str.split("+")[1],str.split("+")[2],str.split("+")[3]     
        end 

        if clientId.to_s.length == 0
            errMsg = "Client Id cannot be blank."
            canAuthenticate = false
        end
        
        if !clientId.to_s.length >= 10 || !clientId.to_s.length <= 50
            errMsg = "Client Id should be greater than 10 and less than 50 characters"
            canAuthenticate = false
        end

        if token.to_s.length != 12
            errMsg = "Invalid token"
            canAuthenticate = false
        end
        
        if accNo.to_s.length != 16
           errMsg = "Invalid account number"
           canAuthenticate = false
        end 

        if custid.length != 8 
            errMsg = "Invalid Customer Id"
            canAuthenticate = false
        end

        if !days.to_s.length >= 1 || !days.to_s.length <= 10
            errMsg = "Number of days should be greater than or equal to 1 and less than or equal to 10"
            canAuthenticate = false
        end

        return canAuthenticate, errMsg  
    end


    #Function validate credentials for app login
	def mobileAuth
        #Request params
        loginType = params[:loginType]
        responseHash = {:status => "invalid"}

        if loginType == "mobile"
            mobile = params[:mobile]
            password = params[:password]
    		if mobile.to_s != "" && password.to_s != ""
    			if mobile == "9999999999" && password == "123456"
    				responseHash = {
    					:status => "valid",
    					:data => {
    						:name => "Avdhut Vaidya",
    						:mobile => "9999999999",
    						:email => "avdhut.vaidya@gmail.com",
    						:aadhar => "123456",
    						:gender => "Male"
    					}
    				}.to_json
    			end
    		end
        elsif loginType == "aadhar"
            aadhar = params[:aadhar]
            password = params[:password]
            if aadhar.to_s != "" && password.to_s != ""
                if aadhar == "123456" && password == "123456"
    				responseHash = {
    					:status => "valid",
    					:data => {
    						:name => "Avdhut Vaidya",
    						:mobile => "9999999999",
    						:email => "avdhut.vaidya@gmail.com",
    						:aadhar => "123456",
    						:gender => "Male"
    					}
    				}.to_json
                end
            end
        elsif loginType == "email"
            email = params[:email]
            password = params[:password]
            if email.to_s != "" && password.to_s != ""
                if email == "avdhut.vaidya@gmail.com" && password == "123456"
    				responseHash = {
    					:status => "valid",
    					:data => {
    						:name => "Avdhut Vaidya",
    						:mobile => "9999999999",
    						:email => "avdhut.vaidya@gmail.com",
    						:aadhar => "123456",
    						:gender => "Male"
    					}
    				}.to_json
                end
            end
        else
            custid = params[:custid]
            accountno = params[:accountno]

			reqParams = {:client_id => $client_id.to_s, :token => $token.to_s, :custid => custid.to_s, :accountno => accountno.to_s}
			requestStr = URI.parse("http://retailbanking.mybluemix.net/banking/icicibank/account_summary?#{reqParams.to_query}")
			puts requestStr
			response = JSON.parse(Net::HTTP.get(requestStr))
			responseHash = {:userData=>response[1]}

			reqParams = {:client_id => $client_id.to_s, :token => $token.to_s, :mobileNo => "9820120461", :emailId => "avdhut.vaidya@gmail.com"}
			requestStr = URI.parse("http://generalinsurance.mybluemix.net/banking/icicibank_general_insurance/getCustomerDtls?#{reqParams.to_query}")
			puts requestStr
			response = JSON.parse(Net::HTTP.get(requestStr))
			responseHash[:code] = response[0]["code"]
			responseHash[:policyData] = response[1]
			responseHash = responseHash.to_json
        end
		
        render :json => responseHash
	end


	def getBranchATMGarage
		locate = params[:locate]
		mapHash = {}

		if locate == "garage"
			mapHash["Anand Garage"] = {
				"address" => "Pandit Jawaharlal Nehru Rd, Industrial Area, Mulund West, Mumbai, Maharashtra 400080",
				"phoneno" => "099209 03842",
				"lattitude" => "19.161466",
				"longitude" => "72.945368"
			}
			mapHash["Francis Auto Garage"] = {
				"address" => "Doctor Baba Saheb Ambedkar Road, Old bdd chawl, Dadar East, Dadar, Mumbai, Maharashtra 400014",
				"phoneno" => "098677 57277",
				"lattitude" => "19.012993",
				"longitude" => "72.844723"
			}
			mapHash["Allied Motor Garage"] = {
				"address" => "193, Andheri Kurla Road, Andheri East, Hanuman Nagar, Andheri East, Mumbai, Maharashtra 400069",
				"phoneno" => "022 2683 1498",
				"lattitude" => "19.114185",
				"longitude" => "72.865652"
			}
			mapHash["Backbay Motor Garage"] = {
				"address" => "T L Waswani Marg, Colaba, Colaba, Chamundeshwari Nagar, Cuffe Parade, Mumbai, Maharashtra 400005",
				"phoneno" => "022 2215 3250",
				"lattitude" => "18.914412",
				"longitude" => "72.820272"
			}
		else
			reqParams = {:client_id => $client_id.to_s, :token => $token.to_s, :locate => locate}
			requestStr = URI.parse("http://retailbanking.mybluemix.net/banking/icicibank/BranchAtmLocator?#{reqParams.to_query}")
			puts requestStr
			responseHash = Net::HTTP.get(requestStr)
			responseHash = JSON.parse(responseHash)

			if responseHash[0]["code"] == 200
				responseHash.each_with_index do |responseData, index|
					if !responseData.has_key?("code")
						if responseData["flag"] == "B"
							branchname = responseData["branchname"]
						else
							branchname = responseData["branchname"] + " " + index.to_s
						end
						mapHash[branchname] = {
							"address" => responseData["address"] + ", " + responseData["city"] + "-" + responseData["pincode"] + ", " + responseData["state"],
							"ifsc" => responseData["IFSC_CODE"],
							"phoneno" => responseData["phoneno"],
							"lattitude" => responseData["lattitude"],
							"longitude" => responseData["longitude"]
						}
					end
				end
			end
		end
		
        render :json => mapHash
	end


	def policyRenewal
		reqParams = {:client_id => $client_id.to_s, :token => $token.to_s, :mobileNo => "9820120461", :emailId => "avdhut.vaidya@gmail.com"}
		requestStr = URI.parse("http://generalinsurance.mybluemix.net/banking/icicibank_general_insurance/getRenewalNotice?#{reqParams.to_query}")
		puts requestStr
		responseHash = Net::HTTP.get(requestStr)
		
        render :json => responseHash
	end

    def getQuickQuote
    	p "in get Quick Quote"

        carname = params[:carname]
        registrationNum = params[:registrationNum]
        regYear = params[:regYear]
        fuelType = params[:fuelType]
        rangeA = params[:rangeA]
        rangeB = params[:rangeA]
        emailId = params[:emaialId]
        mobileNumber = params[:mobileNumber]
        custName = "Swapnil"

        reqParams = {:client_id => $client_id.to_s, :token => $token.to_s, :custName => custName, :mobileNo => "8976325523", :emailId => "swapskate@gmail.com", :manufacturer => "BAJAJ", :model => "Pulsar", :address => "Mumbai", :rto => "MUMBAI", :regDt => "2016-02-08"}
        requestStr = URI.parse("http://generalinsurance.mybluemix.net/banking/icicibank_general_insurance/getQuickQuote?#{reqParams.to_query}")
        puts requestStr
        responseHash = Net::HTTP.get(requestStr)
        
        render :json => responseHash
    end











    def appAuthenticate
        clientId = params[:clientId]
        password = params[:password]
        reqParams = Hash.new
        responseHash = {}
        errMsg = ""
        
        credentials = clientId.to_s + "+" + password.to_s
        isValidCredentials, errMsg = validateCredentials(credentials)


        if isValidCredentials
            reqParams = {:client_id => clientId.to_s, :password => password.to_s}
            requestStr = "http://corporate_bank.mybluemix.net/corporate_banking/mybank/authenticate_client?#{reqParams.to_query}"
            request = Net::HTTP.get(requestStr)
            responseHash = request
            # responseHash = sendURLRequest(requestStr, reqParams)
        else
           responseHash["code"] = "999"
           responseHash["message"] = errMsg.to_s
        end

        render :json => responseHash.to_json
    end

	def getBankBalanceSummary
		clientId = params[:clientId]
		token = params[:accesstoken]
		accNo = params[:accountNumber]

		reqParams = Hash.new
		responseHash = {}
		errMsg = ""
		
        credentials = clientId.to_s + "+" + token.to_s + "+" + accNo.to_s
        isValidCredentials, errMsg = validateCredentials(credentials)


        if isValidCredentials
        	reqParams = {:client_id => clientId.to_s, :token => token.to_s, :accountno => accNo.to_s}
        	requestStr = "http://retailbanking.mybluemix.net/banking/icicibank/balanceenquiry?#{reqParams.to_query}"
        	request = Net::HTTP.get(requestStr)
        	responseHash = request
        	# responseHash = sendURLRequest(requestStr, reqParams)
        else
           responseHash["code"] = "999"
           responseHash["message"] = errMsg.to_s
        end
          
        render :json => responseHash.to_json 
	end	


    def getBankAccountSummary
		clientId = params[:clientId]
		token = params[:accesstoken]
		accNo = params[:accountNumber]
		custid = params[:customerId]

		reqParams = Hash.new
		responseHash = {}
		errMsg = ""
		
        credentials = clientId.to_s + "+" + token.to_s + "+" + accNo.to_s + "+" + custid.to_s
        isValidCredentials, errMsg = validateCredentials(credentials, nil)


        if isValidCredentials
        	reqParams = {:client_id => clientId.to_s, :token => token.to_s, :accountno => accNo.to_s, :custid => custid}
        	requestStr = "http://retailbanking.mybluemix.net/banking/icicibank/account_summary?#{reqParams.to_query}"
        	request = Net::HTTP.get(requestStr)
        	responseHash = request
        	# responseHash = sendURLRequest(requestStr, reqParams)
        else
           responseHash["code"] = "999"
           responseHash["message"] = errMsg.to_s
        end
          
        render :json => responseHash.to_json
    end	

    def getTransactionRecent
		clientId = params[:clientId]
		token = params[:accesstoken]
		accNo = params[:accountNumber]
	
		reqParams = Hash.new
		responseHash = {}
		errMsg = ""
		
        credentials = clientId.to_s + "+" + token.to_s + "+" + accNo.to_s
        isValidCredentials, errMsg = validateCredentials(credentials, "number")

        if isValidCredentials
        	reqParams = {:client_id => clientId.to_s, :token => token.to_s, :accountno => accNo.to_s, :custid => custid}
        	requestStr = "http://retailbanking.mybluemix.net/banking/icicibank/recenttransaction?#{reqParams.to_query}"
        	request = Net::HTTP.get(requestStr)
        	responseHash = request
        	# responseHash = sendURLRequest(requestStr, reqParams)
        else
           responseHash["code"] = "999"
           responseHash["message"] = errMsg.to_s
        end
          
        render :json => responseHash.to_json    	
    end

    def getTransactionHistory
		clientId = params[:clientId]
		token = params[:accesstoken]
		accNo = params[:accountNumber]
		days = params[:days]

		reqParams = Hash.new
		responseHash = {}
		errMsg = ""
		
        credentials = clientId.to_s + "+" + token.to_s + "+" + accNo.to_s + "+" + days.to_s
        isValidCredentials, errMsg = validateCredentials(credentials, "days")


        if isValidCredentials
        	reqParams = {:client_id => clientId.to_s, :token => token.to_s, :accountno => accNo.to_s, :days => days.to_s}
        	requestStr = "http://retailbanking.mybluemix.net/banking/icicibank/ndaystransaction?#{reqParams.to_query}"
        	request = Net::HTTP.get(requestStr)
        	responseHash = request
        	# responseHash = sendURLRequest(requestStr, reqParams)
        else
           responseHash["code"] = "999"
           responseHash["message"] = errMsg.to_s
        end
        render :json => responseHash.to_json    	
    end

    def getTransactionHistoryInterval
        clientId = params[:clientId]
        token = params[:accesstoken]
        accNo = params[:accountNumber]
        fromdate = params[:fromdate]
        todate = params[:todate]


        reqParams = Hash.new
        responseHash = {}
        errMsg = ""
        
        credentials = clientId.to_s + "+" + token.to_s + "+" + accNo.to_s
        isValidCredentials, errMsg = validateCredentials(credentials)
 
        if fromdate > todate
            errMsg = "From date should be greater than to date"
            canAuthenticate = false
        end

        if isValidCredentials
            reqParams = {:client_id => clientId.to_s, :token => token.to_s, :accountno => accNo.to_s, :fromdate => fromdate.to_s, :todate => todate.to_s}
            requestStr = "http://retailbanking.mybluemix.net/banking/icicibank/ndaystransaction?#{reqParams.to_query}"
            request = Net::HTTP.get(requestStr)
            responseHash = request
            # responseHash = sendURLRequest(requestStr, reqParams)
        else
           responseHash["code"] = "999"
           responseHash["message"] = errMsg.to_s
        end
        render :json => responseHash.to_json    
    end



    def sendURLRequest(url, params)
    end

end