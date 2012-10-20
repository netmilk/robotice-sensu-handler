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

    it "should raise" do 

      lambda {
        handle event_descriptor
      }.should raise_error
    end 
  end
end

