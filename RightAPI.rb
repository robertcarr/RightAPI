#!/usr/bin/ruby

##############################################################################
##############################################################################

require 'rubygems'   # not required if ruby >= 1.9

#####
## This is not a complete list of api calls: see API reference
#####

class RightAPI
require 'rest_client'

@apiobject = Object.new
	
attr_accessor :username, :password, :account

	def initialize

	@api =	{	:servers		=> "servers" ,
			:deployments		=> "deployments",
			:ebs			=> "ec2_ebs_volumes",
			:snapshots		=> "ec2_ebs_snapshots",
			:alerts			=> "alert_specs",
			:eips			=> "ec2_elastic_ips",
			:securitygroups		=> "ec2_security_groups",
			:sshkeys		=> "ec2_ssh_keys",
			:arrays			=> "server_arrays",
			:s3			=> "s3_buckets",
			:credentials		=> "credentials",
			:macros			=> "macros",
			:servertemplates	=> "server_templates",
			:rightscripts		=> "right_scripts"
		}

		@logged_in=false

	end
	
	def	login(username, password, account) 
		@username = username
		@password = password
		@account = account
		RestClient.log = 'rest.log'
		@apiobject = RestClient::Resource.new("https://my.rightscale.com/api/acct/#{@account}",@username,@password)
		@logged_in=true
	end

	def	servers_show_all
		# Get /api/acct/1/servers		
		@apiobject[@api[:servers]].get :x_api_version => '1.0'
	
	end

	def	deployments_show_all
		@apiobject[@api[:deployments]].get :x_api_version => '1.0'
	end

	def	ebs_delete(ebsid)
		# URL:  DELETE /api/acct/1/ec2_ebs_volumes/1 
		@apiobject[@api[:ebs]+"/#{ebsid}"].delete :x_api_version => '1.0'
	end

	def	ebs_create(params) 
		#URL: POST /api/acct/1/ec2_ebs_volumes
		@apiobject[@api[:ebs]].post params, :x_api_version => '1.0'
	end

	def 	server_show(serverid)
		@apiobject[@api[:servers]+"/#{serverid}"].get :x_api_version => '1.0'
	end

	def	server_stop(serverid)
		params = {}
		@apiobject[@api[:servers]+"/#{serverid}/stop"].post params, :x_api_version => '1.0'	
	end		

	def	server_start(serverid)
		params = {}
		@apiobject[@api[:servers]+"/#{serverid}/start"].post params, :x_api_version => '1.0'	
	end		

	def	server_update(serverid, params)
		@apiobject[@api[:servers]+"/#{serverid}"].put params, :x_api_version => '1.0'
	end

	def 	run_script(scriptid, serverid)
		params = { "right_script" => "#{scriptid}" }
		puts params.inspect
		#URL: POST /api/acct/1/servers/000/run_script
	
		@apiobject[@api[:servers]+"/#{serverid}/run_script"].post params, :x_api_version => '1.0'
		
	end

	def	server_update_nickname(serverid, name)
		params = { "server[nickname]"	=> "#{name}" }	 
		@apiobject[@api[:servers]+"/#{serverid}"].put params, :x_api_version => '1.0'
	end
	
	def 	show_connection
		puts @apiobject.inspect
	end
	
		
end


