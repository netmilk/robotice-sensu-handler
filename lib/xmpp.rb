require 'xmpp4r/client'
require 'xmpp4r/muc'

class Xmpp
  include Jabber

  attr_reader :handler
  
  def initialize h
    if not h.class == VirtualmasterHandler
      raise StandardError, "First argument must be instance of VirtualmasterHandler"
    end

    if not h.settings['virtualmaster'].keys.include?('xmpp')
      raise StandardError, 'Handler config have to contain "xmpp" section'
    end
    @handler = h
  end

  def send_message(message_text)
    xmpp_jid = self.handler.settings['virtualmaster']['xmpp']['jid']
    xmpp_password = self.handler.settings['virtualmaster']['xmpp']['password']
    xmpp_target = self.handler.settings['virtualmaster']['xmpp']['target']
    xmpp_target_type = self.handler.settings['virtualmaster']['xmpp']['target_type']
    xmpp_server = self.handler.settings['virtualmaster']['xmpp']['server']
   
    jid = JID::new(xmpp_jid)
    cl = Client::new(jid)
    cl.connect(xmpp_server)
    cl.auth(xmpp_password)

    if xmpp_target_type == 'conference'
      m = Message::new(xmpp_target, message_text)
      room = MUC::MUCClient.new(cl)
      room.join(Jabber::JID.new(xmpp_target+'/'+cl.jid.node))
      result = room.send m
      room.exit
    else
      m = Message::new(xmpp_target, message_text).set_type(:normal).set_id('1').set_subject("SENSU ALERT!")
      result = cl.send m
    end
    cl.close
    #TODO return result true/fail from xmpp client
    # result
    true 
  end
end