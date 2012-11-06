#!/usr/bin/env ruby
#
require 'rubygems'
require 'bundler/setup'
Bundler.require

require 'sensu-handler'

require 'net/http'
require 'net/https'

Dir.glob(File.join(File.dirname(__FILE__),'lib','*.rb')).each do |file_path|
  require file_path
end

class VirtualmasterHandler < Sensu::Handler


  attr_reader :xmpp_message
  attr_reader :errors

  def initialize
    @errors = []
  end
  
  def check_name
    @event['check']['name']
  end

  def check_output
    @event['check']['output']
  end
  
  def host_name
    @event['client']['name']
  end
  
  def handle
    f = Foreman.new self
    begin
      data = f.query_host(host_name)
    rescue StandardError => e
      @errors << ErrorHandler.new(e.message)
    end
    
    # compose xmpp message
    msg = ""
    msg = data['redmine_project_url'] if not data.nil?
    msg = msg + " " + data['redmine_priority'] if not data.nil?
    msg = msg + " " + host_name
    msg = msg + " " + check_name
    msg = msg + " " + check_output
    @xmpp_message = msg

    # WIP let's continue with redmine intergration and remove this
    x = Xmpp.new self
    x.send_message(self.xmpp_message)
  end
end


