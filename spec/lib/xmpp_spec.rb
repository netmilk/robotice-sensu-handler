require File.join(File.dirname(__FILE__),'..','spec_helper.rb')

describe Xmpp do
  before do 
    # mock sending xmpp messages globally
    # TODO try to re-invent this to be more DRYer
    # it's already menitoned in virtualmster_spec.rb
    Xmpp.any_instance.stub(:send_message).and_return(true)
  end
  describe "object instance" do
    before do 
      stub_request(:get, "http://sensu1.domain.tld:4567/stash/silence/node1.domain.tld").
        to_return(:status => 200, :body => "", :headers => {})
      stub_request(:get, "http://sensu1.domain.tld:4567/stash/silence/node1.domain.tld/frontend_http_check").
        to_return(:status => 200, :body => "", :headers => {})
    end

    subject{Xmpp.new(handler)}
    it{should respond_to(:handler)}

    it "should raise if first argument is not VirtualmasterHandler" do
      lambda{
        Xmpp.new('some string')
      }.should raise_error
    end
    
    context  "handler settings doeas not contain virtualmster.xmpp" do 
      it do
        h = handle event_mock('without_custom_data')
        h.settings['virtualmaster'].delete('xmpp')

        lambda{
          Xmpp.new h
        }.should raise_error(StandardError, 'Handler config have to contain "xmpp" section')
      end
    end
    
    describe "#send_message" do 
      context "contact_type is not 'conference'" do 
        before do 
 
          Jabber::Client.any_instance.stub(:connect).and_return(true)
          Jabber::Client.any_instance.stub(:auth).and_return(true)
          Jabber::MUC::MUCClient.any_instance.stub(:join){true}

          @h = handle event_mock('without_custom_data')
          Xmpp.any_instance.unstub(:send_message)
        end
        
        it "Jabber::Client should receive :send" do
          Jabber::Client.any_instance.should_receive(:send).at_least(1)
          @h.settings['virtualmaster']['xmpp']['target_type'] = 'client'

          x = Xmpp.new @h
          x.send_message("message")
        end
      end

      context "contact_type is 'conference'"  do 
        before do 
          Jabber::Client.any_instance.stub(:connect).and_return(true)
          Jabber::Client.any_instance.stub(:auth).and_return(true)
          jid_mock = double(Jabber::JID)
          jid_mock.stub(:node) { "node"}
          Jabber::Client.any_instance.stub(:jid).and_return(jid_mock)
          Jabber::MUC::MUCClient.any_instance.stub(:join){true}
          Jabber::MUC::MUCClient.any_instance.stub(:exit){true}
          @h = handle event_mock('without_custom_data')
          Xmpp.any_instance.unstub(:send_message)

        end
        
        it "Jabber::Client should receive :send" do
          Jabber::MUC::MUCClient.any_instance.should_receive(:send).at_least(1)
          x = Xmpp.new @h
          x.send_message("message")
        end
      end
    end
  end
end
