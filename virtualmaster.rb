#!/usr/bin/env ruby
#
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'
require 'net/http'
require 'net/https'

Dir.glob(File.join(File.dirname(__FILE__),'lib','*.rb')).each do |file_path|
  require file_path
end

class VirtualmasterHandler < Sensu::Handler
  attr_reader :xmpp_message

  def event_name
    #@event['client']['name'] + '/' + @event['check']['name']
  end

  def handle
    f = Foreman.new self
    f.query_host(@event['client']['name'])
  end
end


