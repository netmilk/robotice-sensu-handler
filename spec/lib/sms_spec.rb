require File.join(File.dirname(__FILE__),'..','spec_helper.rb')

describe Sms do
  before do 
    stub_request(:get, "http://sensu1.domain.tld:4567/stash/silence/node1.domain.tld").
      with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => "", :headers => {})
    stub_request(:get, "http://sensu1.domain.tld:4567/stash/silence/node1.domain.tld/frontend_http_check").
      with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => "", :headers => {})

    Xmpp.any_instance.stub(:send_message).and_return(true)
  end
  describe "object instance" do 
    subject{Sms.new(handler)}
    it{should respond_to(:handler)}

    it "should raise if first argument is not VirtualmasterHandler" do
      lambda{
        Sms.new('some string')
      }.should raise_error
    end
    describe "#send_message" do 
      context "with success" do 
        before do 
          stub_request(:post, "https://rest.nexmo.com/sms/json").
            with(:body => {"from"=>"Robotice", "password"=>"12345", "text"=>"Hello world!", "to"=>"+420777123456", "username"=>"12345"},
                 :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
            to_return(mock_response('sms/nexmo-success'))
        
          @sms = Sms.new(handle(event_descriptor))
          @result = @sms.send_message('+420777123456', 'Hello world!')
        end
        it "should call nexmo API" do 
          WebMock.should have_requested(:post, 'https://rest.nexmo.com/sms/json')
        end
        it {@result.should eq(true)}
      end

      context "with error" do 
        before do 
          stub_request(:post, "https://rest.nexmo.com/sms/json").
            with(:body => {"from"=>"Robotice", "password"=>"12345", "text"=>"Hello world!", "to"=>"+420777123456", "username"=>"12345"},
                 :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
            to_return(mock_response('sms/nexmo-error'))
          @sms = Sms.new(handle(event_descriptor))
        end

        it "should call nexmo API" do 
          begin
            @sms.send_message('+420777123456', 'Hello world!')
          rescue
            # rescuing everyting, it will raise, because api is mocked to 
            # return error
          end
          WebMock.should have_requested(:post, 'https://rest.nexmo.com/sms/json')
        end
        it "should raise" do 
          lambda{
            @sms.send_message('+420777123456', 'Hello world!')
          }.should raise_error(StandardError)
        end
      end
    end
  end
end
