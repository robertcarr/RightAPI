#!/usr/bin/ruby
# Copyright 2009 RightScale, Inc.
# http://www.rightscale.com
#
# Ruby API Wrapper for RightScale API functions
# Class: RightAPI
#
# Allows easier access to the RightScale API within your own ruby code and
# Has limited debugging & error handling at this point.
# 
# Requires rest_client Ruby gem available online.
# 
# Example:
# api = RightAPI.new	
# api.login(username, password, account)
# api.servers_show("all")	# displays all servers in your account
# api.servers_show(serverid)	# displays server by id
# api.servers_name(serverid, "Servers New Name") 	# updates server name
# api.log = true	# turns on REST log file
# api.debug = true	# limited debugging
#



require 'rubygems'  if VERSION < "1.9.0"  # not required if ruby >= 1.9

class RightAPI
require 'rest_client'
require 'xmlsimple'


@apiobject = Object.new
@apiheader = {}
@resid
@xml

attr_accessor :api_version, :log, :debug, :api_url, :log_file



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
			:status			=> "statuses",
			:getsketchydata		=> "get_sketchy_data",
			:attachtoserver		=> "component_ec2_ebs_volumes",
			:attachvolume		=> "attach_volume",
			:instances		=> "instances",
			:settings		=> "settings",
			:stopall		=> "stop_all",
			:startall		=> "start_all",
			:duplicate		=> "duplicate",
			:runscript		=> "run_script",
			:state			=> "run_right_scripts",
			:operational		=> "operational"
		}

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
		puts e.message	
	end

	def 	headers
		@apiheader
	end

	def	resources
		res_array = []
		data = XmlSimple.xml_in(@xml.to_s)
		key = data.keys[1]
		data[data.keys[1]].each do | item |
			res_array << item['href'].to_s.match(/\d+$/)
		end
		res_array
	end

	def 	debugger
		caller[0][/`([^']*)'/, 1]
	end

	def	show_all(obj)
		reply = @apiobject[@api[obj]].get :x_api_version => "#{@api_version}"
		@apiheader = reply.headers
		@xml=reply
		reply
		
		rescue => e
		puts e.message
	end

	# Creates a common RightScale REST string
	# <obj1> + "/resourceID/ " + <obj2>
	# like : /servers/0000/settings

	def 	makestring(obj1, id, obj2)
		@api[obj1] + "/#{id}/" + @api[obj2]
	end
	
	def	show_item(obj,id)
		if id.to_s.downcase == "all" then
			show_all(obj)
		else
			req=@api[obj].to_s + "/#{id}"
			reply = @apiobject[req].get :x_api_version => "#{@api_version}"
			@apiheader = reply.headers
			@xml=reply
			reply
		end

		rescue => e
		puts e.message		

	end

	def 	post_string(req, params)
		reply = @apiobject[req].post params, :x_api_version => "#{@api_version}"
		@apiheader = reply.headers
		reply.headers[:location].match(/\d+$/)	
		
		puts params.inspect if @debug

		rescue => e
		puts e.message	
	end

	def	put_string(req,params) 
		reply = @apiobject[req].put params, :x_api_version => "#{@api_version}"
		@apiheader = reply.headers
		reply.headers[:location].match(/\d+$/)
	end

	def	get_string(obj)
		reply = @apiobject[obj].get :x_api_version => "#{@api_version}"
		@apiheader = reply.headers
		reply	
	
		rescue => e
		puts e.message
	end

	def	delete_item(obj,id)
		req=@api[obj].to_s + "/#{id}"
		reply = @apiobject[req].delete :x_api_version => "#{@api_version}"
		@apiheader = reply.headers
		reply
		
		rescue => e	
		puts e.message
	end

	def 	create_item(obj, params)
		reply = @apiobject[@api[obj]].post params, :x_api_version => "#{@api_version}"
		@apiheader = reply.headers
	       	@resid = @apiheader[:location].match(/\d+$/) if @apiheader[:status].downcase.match(/201 created/)
		puts params.inspect if @debug
		
		rescue=> e
		puts e.message
	end

	def	update_item(obj, id, params)
		reply = @apiobject[obj + "/#{id}"].put params, :x_api_version => "#{@api_version}"
		@apiheader = reply.headers
		reply
		
		puts params.inpsect if @debug

		rescue=> e
		puts e.message
	end

	def	send(string,type = "get", params = {})
		api_version = { :x_api_version => "#{@api_version}" }
		params.merge!(api_version)
		puts @apiobject[string].send type.to_sym, params
	end



	def	resourceid
		@resid
	end

	def 	instances_state(id, state)
		params = {}
		#put_string(makestring(:instances,id,:operational), params)
		 put_string(makestring(:instances,id,:operational), params)
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
	
	def	arrays_instances(id)
		get_string(makestring(:arrays, id, :instances))
	end
		
	
	def	arrays_show(id)
		show_item(:arrays,id) 
	end
	
	def	credentials_show(id)
		show_item(:credentials,id) 
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
	
	def	servertemplates_show(id)
		show_item(:servertemplates,id) 
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
	
	def	alerts_show(id)
		show_item(:alerts,id) 
	end

	def	eips_create
		params = {}
		create_item(:eips, params)
	end

	def	eips_show(id)
		show_item(:eips,id) 
	end

	def	eips_delete(id)
		delete_item(:eips, id)
	end

	def	alerts_delete(id)
		delete_item(:alerts, id)
	end
	
	def	snapshots_show(id)
		show_item(:snapshots,id) 	
	end	

	def	securitygroups_show(id)
		show_item(:securitygroups,id) 
 	end
	
	def	securitygroups_delete(id)
		delete_item(:securitygroups, id)
	end
	
	def	sshkeys_show(id)
		show_item(:sshkeys,id) 
	end
	
	
	def	sshkeys_create(keyname)
		params = { "ec2_ssh_key[aws_key_name]" => keyname }
		create_item(:sshkeys, params)
	end
	
	def	sshkeys_delete(id)
		delete_item(:sshkeys, id)
	end
	
	def	deployments_start_all(id)
		params = {}
		post_string(makestring(:deployments, id, :startall), params)
	end

	def	deployments_stop_all(id)
		params = {}
		post_string(makestring(:deployments,id,:stopall), params)
	end

	def	deployments_create(nickname,description)
		params = { "deployments[nickname]" => nickname, "deployments[description]" => description }
		create_item(:deployments, params)
	end

	def	deployments_copy(id)
		params = {}
		post_string(makestring(:deployments, id, :duplicate), params)
	end

	def	deployments_delete(id)
		delete_item(:deployments, id)
	end

	def	deployments_show(id)
		show_item(:deployments,id)
	end

	def	status(id)
		show_item(:status, id)
	end

	def	ebs_show(id)
		show_item(:ebs,id)
	end
	
	def	ebs_delete(id)
		delete_item(:ebs, id)
	end

	def	ebs_create(params) 
		create_item(:ebs, params)
	end

	def	ebs_attach(params)
		create_item(:attachtoserver, params)
	end 

	def	servers_delete(id)
		delete_item(:servers,id)
	end

	def 	servers_show(id)
		show_item(:servers,id) 		
	end

	def	servers_settings(id)
		get_string(makestring(:servers,id,:settings))
	end

	def	servers_stop(serverid)
		params = {}
		post_string(makestring(:servers,id,:stop), params)
	end		

	def	servers_start(serverid)
		params = {}
		post_string(makestring(:servers,id,:start), params)
	end		

	def	servers_attach_volume(id,params)
		post_string(makestring(:servers,id,:attachvolume), params)
	end

	def	servers_update(id, params)
		update_item(id, params)
	end

	def 	run_script(scriptid, serverid)
		params = { "right_script" => "#{scriptid}" }
		post_string(makestring(:servers,id,:runscript), params)	
	end

	def	servers_name(id, name)
		params = { "server[nickname]"	=> name }	 
		update_item(@api[:servers],id, params)
	end

	def	servers_getsketchydata(id)
		get_string(makestring(:servers,id,:getsketchydata))
	end

	def 	show_connection
		puts @apiobject.inspect
	end
	
	
private :show_all, :show_item, :delete_item, :post_string, :create_item, :update_item
private :debugger, :get_string, :makestring

end

