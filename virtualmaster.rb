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
  attr_reader :redmine

  def initialize
    @errors = []
    @redmine = {}
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
      foreman_data = f.query_host(host_name)
    rescue StandardError => e
      @errors << ErrorHandler.new(e.message)
    end
   
    if not foreman_data.nil?
      @redmine['url'] = foreman_data['redmine_url']
      @redmine['project'] = foreman_data['redmine_project']
      @redmine['priority'] = foreman_data['redmine_priority']
    end
    
    # compose xmpp message
    msg = "#{@redmine['priority']} #{@redmine['project']} #{host_name} #{check_name} #{check_output} #{@redmine['url']}"

    @xmpp_message = msg

    # WIP let's continue with redmine intergration and remove this
    x = Xmpp.new self
    x.send_message(self.xmpp_message)
  end
end


