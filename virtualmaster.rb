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
  attr_reader :issue

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

      @issue = {
        :issue => {
          :project_id => @redmine['project'],
          :subject => "#{host_name} #{check_name}",
          :priority_id => '4',
          :description => check_output
        }
      }
      created_issue = Redmine.new(self).create_issue(@issue)

      if not created_issue == false
        #override redmine base url with issue url to be sent in XMPP message
        issue_id = created_issue['issue']['id']
        @redmine['url'] = @redmine['url'] + '/issues/' + issue_id.to_s
      end
    end

    # compose xmpp message
    @xmpp_message = "#{@redmine['priority']} #{@redmine['project']} #{host_name} #{check_name} #{check_output} #{@redmine['url']}"

    # send XNPP in any case
    x = Xmpp.new self
    x.send_message(self.xmpp_message)
  end
end


