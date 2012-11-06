class Sms
  attr_reader :handler
  def initialize h
    if not h.class == VirtualmasterHandler
      raise StandardError, "First argument must be instance of VirtualmasterHandler"
    end
    if not h.settings['virtualmaster'].keys.include?('sms')
      raise StandardError, 'Handler config have to contain "sms" section'
    end

    @handler = h
  end

  def send_message  to, text
    key = handler.settings['virtualmaster']['sms']['key']
    secret = handler.settings['virtualmaster']['sms']['secret']
    from = handler.settings['virtualmaster']['sms']['from']
    nexmo = Nexmo::Client.new(key, secret)

    response = nexmo.send_message({
      :from => from,
      :to => to,
      :text => text
    })

    if response.success?
      return true
    elsif response.failure?
      raise StandardError, "Error sending SMS: #{response.error}"
    end
  end
end