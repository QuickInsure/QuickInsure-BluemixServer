require 'net/http'
require 'json'

class LoginController < ApplicationController
	def mobileAuth
		username = params[:username]
		password = params[:password]

        puts "in mobileAuth"

		if username.to_s == "" && password.to_s == ""
			flag = nil
		else
			flag = false
			if username == "avdhut.vaidya" && password == "123456"
				flag = true
			end
		end
        puts "in mobileAuth beforerender"
        return "HI you are authenticated!".to_s
		#render :text => "HI you are authenticated!".to_s
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



    def sendURLRequest(url, params)
    end


end