require File.join(File.dirname(__FILE__),'spec_helper.rb')

describe VirtualmasterHandler do 
  describe "handler instance" do 
    subject{ VirtualmasterHandler.new }
    
    it{should respond_to(:xmpp_message)}


    describe "#handle" do
      before do
        # stubbing web requests
        stub_request(:get, "http://sensu1.domain.tld:4567/stash/silence/node1.domain.tld").
          with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => "", :headers => {})
        stub_request(:get, "http://sensu1.domain.tld:4567/stash/silence/node1.domain.tld/frontend_http_check").
           with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
           to_return(:status => 200, :body => "", :headers => {})
      end

      it "should create Foreman lookup" do 
        Foreman.any_instance.should_receive(:query_host).with('node1.domain.tld')
        handle event_descriptor
      end

      context "Foreman responds correctly" do
        describe "compiled XMPP message" do 
          it "should containg priority class"
          it "should contain Redmine project"
          it "should contain Sensu check output"
        end
      end

      context "Foreman is not available" do
        it "should send SMS message"
      end

    
      context "Redmine is not available" do
        it "should send SMS message"
        it "should send XMPP message without isseu"
      end
      
      context "Redmine is available" do 
        it "should create new Redmine issue (Steering wheel)"

        describe "compiled XMPP message" do
          it "should contain event Redmine issue"
        end
        
        it "should send compiled message via XMPP"
      end
      
      context "XMPP message sending failed" do 
        it "should send SMS message"
      end
    end
  end
end

