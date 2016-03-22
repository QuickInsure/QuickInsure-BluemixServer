require 'net/http'
require 'json'

class LoginController < ApplicationController
	before_filter :iciciTokenInitialize
	
	def iciciTokenInitialize
		#ICICI authentication params
		client_id = "avdhut.vaidya@gmail.com"
		client_password = "ICIC8058"

		reqParams = {:client_id => client_id.to_s, :password => client_password.to_s}
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

        token = ""
        response = false

        if loginType == "mobile"
            mobile = params[:mobile]
            password = params[:password]
    		if mobile.to_s != "" && password.to_s != ""
    			if mobile == "9999999999" && password == "123456"
    				response = true
    			end
    		end
        elsif loginType == "aadhar"
            aadhar = params[:aadhar]
            password = params[:password]
            if aadhar.to_s != "" && password.to_s != ""
                if aadhar == "123456" && password == "123456"
                    response = true
                end
            end
        elsif loginType == "email"
            email = params[:email]
            password = params[:password]
            if email.to_s != "" && password.to_s != ""
                if email == "avdhut.vaidya@gmail.com" && password == "123456"
                    response = true
                end
            end
        else
            custid = params[:custid]
            accountno = params[:accountno]
            # errMsg = ""
            # credentials = username.to_s + "+" + password.to_s
            # isValidCredentials, errMsg = validateCredentials(credentials)

            # if isValidCredentials
                # reqParams = {:client_id => client_id.to_s, :password => client_password.to_s}
                # requestStr = URI.parse("http://corporate_bank.mybluemix.net/corporate_banking/mybank/authenticate_client?#{reqParams.to_query}")
                # response = Net::HTTP.get(requestStr)
                # puts response
                # token = JSON.parse(response)[0]["token"]
                # puts token

                reqParams = {:client_id => client_id.to_s, :token => $token.to_s, :custid => custid.to_s, :accountno => accountno.to_s}
                requestStr = URI.parse("http://retailbanking.mybluemix.net/banking/icicibank/account_summary?#{reqParams.to_query}")
                puts requestStr
                response = Net::HTTP.get(requestStr)
            # else
            #     response["code"] = "999"
            #     response["message"] = errMsg.to_s
            # end
        end
		
        respond_to do |format|
            format.html { render :text => response.to_s }
            format.js   { render :text => response.to_s }
            format.json { render :json => response.to_json }
        end
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