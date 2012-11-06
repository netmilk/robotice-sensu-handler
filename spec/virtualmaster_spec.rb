require File.join(File.dirname(__FILE__),'spec_helper.rb')

describe VirtualmasterHandler do 
  describe "handler instance" do 
    before do
      # mock sending xmpp messages globally
      Xmpp.any_instance.stub(:send_message).and_return(true)
    end

    subject{ VirtualmasterHandler.new }
    
    it{should respond_to(:xmpp_message)}
    it{should respond_to(:errors)}
    
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


      context "Foreman raises error" do
        before do
          stub_request(:get, "http://foreman.domain.tld/node/node1.domain.tld?format=yml").
            with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
            to_return(mock_response('foreman/host_not_found'))
        end
        subject{handle event_descriptor}

        it "should create error message" do 
          subject.errors.length.should eq(1)
        end
        
        it "should notify new error" do 
          ErrorHandler.any_instance.should_receive(:notify)
          handle event_descriptor
        end
      end

      context "Foreman responds correctly" do
        before do 
          stub_request(:get, "http://foreman.domain.tld/node/node1.domain.tld?format=yml").
            with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
            to_return(mock_response('foreman/valid_response'))

          @handler = handle event_descriptor
        end

        context "host does not exist in foreman or exists without metadata" do
          it "should create some low priority notification"
        end

        context "host exists in foreman and has set metadata" do
          describe "compiled XMPP message" do 
            subject{@handler.xmpp_message}

            it "should containg priority class" do 
              should include("Immediate")
            end

            it "should set priority class based on severity (Critical > Immediate, Warning > Normal)"

            it "should contain Redmine project" do 
              should include("mng-magiclab")
            end

            it "should contain Sensu check output" do 
              should include("HTTP CRITICAL")
            end

            it "should contain affected host" do
              should include("node1.domain.tld")
            end

            it "should contain Sensu check name" do 
              should include("frontend_http_check")
            end
          end
        end
      end
      # WIP let's continue with redmine intergration and remove this
      context "jabber contact is conference" do 
        it "should send xmpp message" do
          Xmpp.any_instance.should_receive(:send_message)
          handle event_descriptor
        end
      end
      
      context "Redmine is not available" do
        pending "should create error message" do 
          subject.errors.length.should eq(1)
        end
        it "should send XMPP message without issue"
      end
      
      context "Redmine is available" do 
        it "should create new Redmine issue (Steering wheel)"

        describe "compiled XMPP message" do
          it "should contain event Redmine issue"
        end
        
        it "should send compiled message via XMPP"
      end
      
      context "XMPP message sending failed" do 
        it "should send error message"
      end
    end
  end
end

