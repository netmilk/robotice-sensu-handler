require File.join(File.dirname(__FILE__),'..','spec_helper.rb')



describe Foreman do
  before do 

    stub_request(:get, "http://sensu1.domain.tld:4567/stash/silence/node1.domain.tld").
      with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => "", :headers => {})
    stub_request(:get, "http://sensu1.domain.tld:4567/stash/silence/node1.domain.tld/frontend_http_check").
      with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => "", :headers => {})

    stub_request(:get, "http://foreman.domain.tld/node/node1.domain.tld?format=yml").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(mock_response('foreman/valid_response'))
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
        h = handle event_descriptor
        h.settings['virtualmaster'].delete('foreman')
        lambda{
          Foreman.new h
        }.should raise_error(StandardError, 'Handler config have to contain "foreman" section')
      end
    end

    describe " #query_host" do
      before do 
        @f = Foreman.new(handle(event_descriptor))
      end
      
            
      it "should make HTTP request" do
        host = settings['virtualmaster']['foreman']['host']
        url = host + '/node/node1.domain.tld?format=yml'
        WebMock.should have_requested(:get, url)
      end
      
      context "Foreman is down" do
        before do 
          stub_request(:get, "http://foreman.domain.tld/node/node1.domain.tld?format=yml").
            with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
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
              with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
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
              with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
              to_return(mock_response('foreman/host_not_found'))
          end 
          it do 
            lambda{
              subject.query_host('node1.domain.tld')
            }.should raise_error(StandardError, "Foreman does not know host 'node1.domain.tld'")
          end
        end

        context "host exists in Foreman" do 
          context "host has not all require fields" do
            before do 
              stub_request(:get, "http://foreman.domain.tld/node/node1.domain.tld?format=yml").
                with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
                to_return(mock_response('foreman/without_parameters'))
            end
            
            it do 
              lambda{
                subject.query_host('node1.domain.tld')
              }.should raise_error(StandardError, "Host 'node1.domain.tld' has not required data in Foreman")
            end
          end

          context "host has all required fields" do
            subject{
              f = Foreman.new(handler)
              f.query_host('node1.domain.tld')
            }

            it{should be_kind_of(Hash)}

            describe "returned hash" do 
              ['redmine_project_url','redmine_priority'].each do |key|
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
