#!/usr/bin/env ruby
#
require 'rubygems'
require 'bundler'
Bundler.require

require 'sensu-handler'

require 'net/http'
require 'net/https'

Dir.glob(File.join(File.dirname(__FILE__),'lib','*.rb')).each do |file_path|
  require file_path
end

#TODO refactor this
def debug message
 #puts message
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
    #IGNORE ALL NON CRITICAL EVENTS
    #0 OK
    #1 WARNING
    #2 CRITICAL
    return false if not @event['check']['status'].to_s == '2'
    
    f = Foreman.new self
    begin
      debug "Foreman lookup for host: #{host_name}"
      foreman_data = f.query_host(host_name)
      debug "Foreman lookup successful"
    rescue StandardError => e
      @errors << ErrorHandler.new(e)
    end
    if not foreman_data.nil?
      debug "Foreman data:"
      debug @redmine['url'] = foreman_data['redmine_url']
      debug @redmine['project'] = foreman_data['redmine_project']
      debug @redmine['priority'] = foreman_data['redmine_priority']

      @issue = {
        :issue => {
          :project_id => @redmine['project'],
          :subject => "#{host_name} #{check_name}",
          :priority_id => '4',
          :description => check_output + "\n\nJSON:\n<pre>" + JSON.pretty_generate(@event) + "</pre>"
        }
      }
      
      if @event.keys.include?('custom_data')
        if @event['custom_data']['redmine_issue_url'].nil?
          debug "Event JSON doesn't contain 'redmine_issue_url', creating issue."
          created_issue = Redmine.new(self).create_issue(@issue)
          debug "Created issue: #{created_issue}"

          if not created_issue == false
            #override redmine base url with issue url to be sent in XMPP message
            issue_id = created_issue['issue']['id']
            @redmine['url'] = @redmine['url'] + 'issues/' + issue_id.to_s
            debug "New Redmine issue ID: #{issue_id}, adding to Redis"
            r = SensuRedis.new(self)
            r.update_event_redmine_issue_url(@redmine['url'])
          end
        else
          debug "Event JSON contains 'redmine_issue_url', do not creating issue."
        end
      end
    end

    # compose xmpp message
    debug "Compiled XMPP message to send:"
    debug @xmpp_message = "#{@redmine['priority']} #{@redmine['project']} #{host_name} #{check_name} #{check_output} #{@redmine['url']}"
    
    # send XMPP in any case
    x = Xmpp.new self
    if x.send_message(self.xmpp_message)
      debug "XMPP message sent successfullly"
    else
      debug "XMPP message sending failed"
    end
    
  end
end


