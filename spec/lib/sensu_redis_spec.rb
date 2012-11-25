require File.join(File.dirname(__FILE__),'..','spec_helper.rb')

describe SensuRedis do
  before do 
    stub_request(:get, "http://sensu1.domain.tld:4567/stash/silence/node1.domain.tld").
      to_return(:status => 200, :body => "", :headers => {})
    stub_request(:get, "http://sensu1.domain.tld:4567/stash/silence/node1.domain.tld/frontend_http_check").
      to_return(:status => 200, :body => "", :headers => {})

    Xmpp.any_instance.stub(:send_message).and_return(true)

    @handler = handle event_mock('without_redmine_issue')
  end

  describe 'instance' do 
    subject{SensuRedis.new(@handler)}
    it{should respond_to(:handler)}
    it{should respond_to(:update_event_redmine_issue_url)}
  end
  
  describe '#update_event_redmine_issue_url' do
    before do
      json_path = File.join(File.dirname(__FILE__),'../responses/redis/event.json')
      json =  File.open(json_path, 'rb') { |f| f.read }

      @redis_mock = MockRedis.new
      Redis.stub(:new).and_return(@redis_mock)

      @redis_mock.hset('events:' + 'node1.domain.tld', 'frontend_http_check', json)

      url = "http://redmine.doman.tld/issues/1.json"
      @result = SensuRedis.new(@handler).update_event_redmine_issue_url url
    end

    subject{@result}

    it{should be_true}
    it "should custom_data.redmine_issue_url should not be nil" do
      json = @redis_mock.hget('events:' + 'node1.domain.tld', 'frontend_http_check')
      puts json
      data = JSON.parse(json)
      data['custom_data']['redmine_issue_url'].should_not be_nil
    end
    
  end
end
