#!/usr/bin/env ruby
#
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'

class VirtualmasterHandler < Sensu::Handler
  attr_reader :xmpp_message

  def event_name
    #@event['client']['name'] + '/' + @event['check']['name']
  end

  def handle
    raise "Raised"
  end
end


