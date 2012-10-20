#!/usr/bin/env ruby
#
# This handler creates Redmine issues for incidents
#
# Copyright 2012 Virtualmaster
#

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'
require 'net/http'
require 'json'

class Redmine < Sensu::Handler

  def event_key
    @event['client']['name'] + '/' + @event['check']['name']
  end

  def handle
    description = @event['notification'] || [@event['client']['name'], @event['check']['name'], @event['check']['output']].join(' : ')
    data = {
      "subject" => event_key,
      "project_id" => "test-monitor",
      "priority_id" => "1"
    }.to_json
    begin
      timeout(3) do
        http = Net::HTTP.new(settings['redmine']['server'], settings['redmine']['port'])
        http.use_ssl = settings['redmine']['use_ssl']
        http.body = data
        http.start do |http|
          req = Net::HTTP::Post.new('/issues.json', initheader = {'Content-Type' =>'application/json'})
          req.basic_auth settings['redmine']['user'], settings['redmine']['password']
          response, data = http.request(req)
          if response['status'] == 'success'
            puts 'redmine - ' + @event['action'] + 'd issue for event ' + event_key
          else
            puts 'redmine - failed to ' + @event['action'] + ' issue for event ' + event_key
          end
        end
      end
    rescue Timeout::Error
      puts 'redmine - timed out while attempting to ' + @event['action'] + 'issue for current incident ' + event_key
    end
  end

end
