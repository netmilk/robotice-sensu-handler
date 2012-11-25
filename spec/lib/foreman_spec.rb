require File.join(File.dirname(__FILE__),'..','spec_helper.rb')

describe Foreman do
  before do 
    stub_request(:get, "http://sensu1.domain.tld:4567/stash/silence/node1.domain.tld").
      to_return(:status => 200, :body => "", :headers => {})
    stub_request(:get, "http://sensu1.domain.tld:4567/stash/silence/node1.domain.tld/frontend_http_check").
      to_return(:status => 200, :body => "", :headers => {})
    stub_request(:get, "http://foreman.domain.tld/node/node1.domain.tld?format=yml").
      to_return(mock_response('foreman/valid_response'))
    stub_request(:post, "http://redmine.domain.tld/issues.json?key=s3c43tmuchmuchlonger").
      to_return(:status => 200, :body => "", :headers => {})
    # mock sending xmpp messages globally
    # TODO try to re-invent this to be more DRYer
    # it's already menitoned in virtualmster_spec.rb
    Xmpp.any_instance.stub(:send_message).and_return(true)
  end
  describe "object instance" do

    subject{Foreman.new(handler)}
    it{should respond_to(:handler)}

    it "should raise if first argument is not VirtualmasterHandler" do
      lambda{
        Foreman.new('some string')
      }.should raise_error
    end
    
    context  "handler settings doeas not contain virtualmster.foreman" do 
  
      it do
        h = handle event_mock('without_custom_data')
        h.settings['virtualmaster'].delete('foreman')
        lambda{
          Foreman.new h
        }.should raise_error(StandardError, 'Sensu handler config have to contain "foreman" section')
      end
    end

    describe " #query_host" do
      before do 
        @f = Foreman.new(handle(event_mock('without_custom_data')))
      end
      
            
      it "should make HTTP request" do
        host = settings['virtualmaster']['foreman']['host']
        url = host + '/node/node1.domain.tld?format=yml'
        WebMock.should have_requested(:get, url)
      end
      
      context "Foreman is down" do
        before do 
          stub_request(:get, "http://foreman.domain.tld/node/node1.domain.tld?format=yml").
            to_raise("Errno::ECONNREFUSED","Connection refused - connect(2)")
        end
        it do 
          lambda{
            subject.query_host('node1.domain.tld')
          }.should raise_error(StandardError, "Foreman is down or not reachable")
        end
      end
      
      context "Foreman is available" do 
        context "it takes more than timeout limit in config" do
          before do 
            stub_request(:get, "http://foreman.domain.tld/node/node1.domain.tld?format=yml").
              to_timeout
          end
          it do
            limit = settings['virtualmaster']['foreman']['timeout']
            lambda{
              subject.query_host('node1.domain.tld')
            }.should raise_error(StandardError, "Foreman timeouted after #{limit} seconds.")
          end
        end
        
        context "host does not exist in Foreman" do
          before do 
            stub_request(:get, "http://foreman.domain.tld/node/node1.domain.tld?format=yml").
              with().
              to_return(mock_response('foreman/host_not_found'))
          end 
          it do 
            subject.query_host('node1.domain.tld').should be_false
          end
        end

        context "host exists in Foreman" do 
          context "host has not all require fields" do
            before do 
              stub_request(:get, "http://foreman.domain.tld/node/node1.domain.tld?format=yml").
                with().
                to_return(mock_response('foreman/without_parameters'))
            end
            
            it do 
              subject.query_host('node1.domain.tld').should be_nil
            end
          end

          context "host has all required fields" do
            subject{
              f = Foreman.new(handler)
              f.query_host('node1.domain.tld')
            }

            it{should be_kind_of(Hash)}

            describe "returned hash" do 
              ['redmine_url','redmine_priority','redmine_project'].each do |key|
                it "should contain key '#{key}'" do
                  subject.keys.should include(key)
                end
              end
            end
          end
        end
      end
    end
  end
end
