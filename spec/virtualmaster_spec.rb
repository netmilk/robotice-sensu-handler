require File.join(File.dirname(__FILE__),'spec_helper.rb')

def event_descriptor
  event_path = File.join(File.dirname(__FILE__), 'event.json')
  f = File.open(event_path,'r')
  f
end

# at_exit is monkeypatch to avoid Handler::Sensu hang
# we need to call that overrriden block manually in each test
def handle event_data
  handler = VirtualmasterHandler.new
  handler.read_event(event_data)
  handler.filter
  handler.handle
  #handler
end

describe VirtualmasterHandler do 
  describe "handler instance" do 
    it "should have attr reader #xmpp_message" do
      should
    end

    describe "#handle" do
      before do
        # stubbing web requests
        stub_request(:get, "http://sensu1.dom.tld:4567/stash/silence/host01").
           with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
           to_return(:status => 200, :body => "", :headers => {})

        stub_request(:get, "http://sensu1.dom.tld:4567/stash/silence/host01/frontend_http_check").
           with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
           to_return(:status => 200, :body => "", :headers => {})
      end

      # will be removed when implementation starts
      #  it's here only to see test working
      it "should raise" do 
        lambda {
          handle event_descriptor
        }.should raise_error
      end 

      it "should create Foreman lookup"

      context "Foreman is not available" do
        it "should send SMS message"
      end

      describe "compiled XMPP message" do 
        it "should containg priority class"
        it "should contain Redmine project"
        it "should contain Sensu check output"
      end 

      it "should create new Redmine issue (Steering wheel)"
    
      context "Redmine is not available" do
        it "should send SMS message"
        it "should send XMPP message without isseu"
      end
      
      context "Redmine is available" do 
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

