#!/usr/bin/ruby
#
# Copyright 2009 RightScale, Inc.
# http://www.rightscale.com
# robert@rightscale.com
#
# Ruby API Wrapper for RightScale API functions
# Class: RightAPI
#
# Allows easier access to the RightScale API within your own ruby code and
# Has limited debugging & error handling at this point.
# 
# Requires rest_client Ruby gem available online.
# 'gem install rest-client' 
#  
# Example:
# api = RightAPI.new	
# api.log = true
# api.login(username, password, account)
# 
# Allows you to send API messages to RightScale in a standard format (see API reference)
# http://support.rightscale.com/15-References/RightScale_API_Reference_Guide
#
#
# api.send(API_STRING,REST_TYPE, PARAMS)
# 	e.g.	API_STRING = "ec2_ssh_keys/1234"
#		REST_TYPE = GET | PUT | POST | DELETE 		
#		PARAMS = optional depending on call
#
# api.send("servers") 				Returns list of your servers
# 
# params = { 'deployment[nickname]' => 'my_deployment_name', 'deployment[description]' => 'my_description' }
# api.send("deployments","post",params)
#


require 'rubygems'  if VERSION < "1.9.0"  # not required if ruby >= 1.9

class RightAPI
require 'rest_client'

@apiobject = Object.new
@apiheader = {}
@resid

attr_accessor :api_version, :log, :debug, :api_url, :log_file

	def initialize

	@api_version = '1.0' if @api_version == nil	# Change default API version
	@log_file_default = "rest.log"
	@api_url = "https://my.rightscale.com/api/acct/" if @api_url == nil

	end
	
	def	login(username, password, account) 
		puts "Debug mode on\n\n" if @debug
		
		@username = username
		@password = password
		@account = account
		@api_call = "#{@api_url}#{@account}"
		unless @log.nil?
			puts "logging=#{@log}" if @debug
			puts "log_file=#{@log_file}" if @debug
			@log_file == nil ? RestClient.log = "#{@log_file_default}" : RestClient.log = "#{@log_file}"
		end
		@apiobject = RestClient::Resource.new("#{@api_call}",@username,@password)
		rescue => e
		puts "Error: #{e.message}"
	end

	def 	headers
		@apiheader
	end

	def 	debugger
		caller[0][/'([^']*)'/, 1]
	end

		# A better way to handle api calls with fewer methods
		# Convert all the API calls later. 

	def	send(apistring,type = "get", params = {})
		api_version= { :x_api_version => "#{@api_version}" }

	
		raise "No API call given" if apistring.empty?
		raise "Invalid Action: get | put | post | delete only" unless type.match(/(get|post|put|delete)/)
		
		if params.empty?
			reply = @apiobject[apistring].send(type.to_sym, api_version) 
		else 
			reply = @apiobject[apistring].send(type.to_sym, params, api_version)
		end

		@apiheader = reply.headers
		@resid = @apiheader[:location].match(/\d+$/) if @apiheader[:status].downcase.match(/201 created/)
	
		reply 	

		rescue
		puts "Error: #{$!}"	

	end

	def	resourceid
		@resid
	end

	def 	show_connection
		puts @apiobject.inspect
	end
	
end
