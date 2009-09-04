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
	
attr_accessor :api_version, :log
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
			:rightscripts		=> "right_scripts",
			:status			=> "statuses"
		}

	api_version='1.0' if api_version == nil

	end
	
	def	login(username, password, account) 
		@username = username
		@password = password
		@account = account
		if @log == true 
			RestClient.log = 'rest.log'
		end
		@apiobject = RestClient::Resource.new("https://my.rightscale.com/api/acct/#{@account}",@username,@password)
		@logged_in=true
	end

	def	servers_show_all
		# Get /api/acct/1/servers		
		show_all(:servers)
	end
	
	def	show_all(obj)
		@apiobject[obj].get :x_api_version => '1.0'
	end

	def	show_item(obj,id)
		req=@api[obj].to_s + "/#{id}"
		@apiobject[req].get :x_api_version => '1.0'
	end

	def 	post_string(req, params)
		@apiobject[req].post params, :x_api_version => '1.0'
	end

	def	delete_item(obj,id)
		req=@api[obj].to_s + "/#{id}"
		@apiobject[req].delete :x_api_version => '1.0'	
	end

	def 	create_item(obj, params)
		@apiobject[obj].post params, :x_api_version => '1.0'		
	end

	def	update_item(obj, id, params)
		@apiobject[obj + "/#{id}"].put params, :x_api_version => '1.0'
	end

	def	arrays_create(params)
		create_item(:arrays, params)
	end
	
	def	arrays_update(arrayid,params)
		update_item(:arrays, arrayid, params)
	end
	
	def	arrays_delete(id)
		delete_item(:arrays, id)
	end
	
	def	arrays_show(id)
		show_item(:arrays,id)
	end
	
	def	credentials_show_all
		show_all(:credentials)
	end
	
	def	credentials_show(id)
		show_item(:credentials, id)
	end
	
	def	credentials_create(params)
		create_item(:credentials, params)
	end
	
	def	credentials_update(id,params)
		update_item(:credentials.to_s, id, params)
	end
	
	def	credentials_delete(id)
		delete_item(:credentials, id)
	end
	
	def	servertemplates_show_all
		show_all(:servertemplates)
	end
	
	def	servertemplates_show(id)
		show_item(:servertemplates,id)
	end
	
	def	arrays_show_all
		show_all(:arrays)
	end
	
	def	s3_show(id)
		show_item(:s3,id)
	end
	
	def	s3_delete(id)
		delete_item(:s3, id)
	end
	
	def	s3_create(name)
		params = { "s3_bucket[name]" => name }
		create_item(:s3, params)
	end
	
	def	s3_show_all
		show_all(:s3)	
	end
	
	def	alerts_show_all
		show_all(:alerts)
	end
	
	def	alerts_show(id)
		show_item(:alerts, id)
	end

	def	eips_show_all
		show_all(:eips)
	end

	def	eips_create
		params = {}
		create_item(:eips, params)
	end

	def	eips_show(id)
		show_item(:eips, id)
	end

	def	eips_delete(id)
		delete_item(:eips, id)
	end

	def	alerts_delete(id)
		delete_item(:alerts, id)
	end
	
	def	deployments_show_all
		show_all(:deployments)
	end

	def	snapshots_show_all
		show_all(:snapshots)
	end
	
	def	securitygroups_show_all
		show_all(:security_groups)
	end
	
	def	securitygroups_show(id)
		show_item(:securitygroups, id)
	end
	
	def	securitygroups_delete(id)
		delete_item(:securitygroups, id)
	end
	
	def	sshkeys_show(id)
		show_item(:sshkeys, id)
	end
	
	def	sshkeys_create(keyname)
		params = { "ec2_ssh_key[aws_key_name]" => keyname }
		create_item(:sshkeys, params)
	end
	
	def	sshkeys_delete(id)
		delete_item(:sshkeys, id)
	end
	
	def	deployments_start_all(id)
                #URL: POST /api/acct/1/deployments/000/start_all
		params = {}
		req=:deployments.to_s + "/#{id}/start_all"
		post_string(req, params)
	end

	def	deployments_stop_all(id)
                #URL: POST /api/acct/1/deployments/000/start_all
		params = {}
		req=:deployments.to_s + "/#{id}/stop_all"
		post_string(req, params)
	end

	def	deployments_create(nickname,description)
		#URL: POST /api/acct/1/deployments
		params = { "deployments[nickname]" => nickname, "deployments[description]" => description }
		create_item(:deployments, params)
	end

	def	deployments_copy(id)
                #URL: POST /api/acct/1/deployments/000/start_all
		params = {}
		req=:deployments.to_s + "/#{id}/duplicate"
		post_string(req, params)
	end

	def	deployments_delete(id)
                #URL: POST /api/acct/1/deployments/000
		delete_item(:deployments, id)
	end

	def	deployments_show(id)
                #URL: GET /api/acct/1/deployments/1
		show_item(:deployments, id)
	end

	def	status(id)
		#URL:  GET /api/acct/1/statuses/000
		show_item(:status, id)
	end
	
	def	ebs_delete(id)
		# URL:  DELETE /api/acct/1/ec2_ebs_volumes/1 
		delete_item(:ebs, id)
	end

	def	ebs_create(params) 
		#URL: POST /api/acct/1/ec2_ebs_volumes
		create_item(:ebs, params)
	end

	def	server_delete(id)
		delete_item(:servers,id)
	end
	def 	server_show(id)
		show_item(:servers, id)
	end

	def	server_stop(serverid)
		params = {}
		req=:servers.to_s + "/#{serverid}/stop"
		post_string(req, params)
	end		

	def	server_start(serverid)
		params = {}
		req=:servers.to_s + "/#{serverid}/start"
		post_string(req, params)
	end		

	def	server_update(id, params)
		update_item(id, params)
	end

	def 	run_script(scriptid, serverid)
		#URL: POST /api/acct/1/servers/000/run_script
		params = { "right_script" => "#{scriptid}" }
		req=:servers.to_s + "/#{serverid}/run_script"
		post_string(req, params)	
	end

	def	server_update_nickname(id, name)
		params = { "server[nickname]"	=> name }	 
		update_item(:servers.to_s,id, params)
	end
	
	def 	show_connection
		puts @apiobject.inspect
	end
	

private :show_all
private :show_item
end
