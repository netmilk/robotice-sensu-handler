class SensuRedis
  attr_reader :handler
  attr_reader :redis

  def initialize(h)
    @handler = h
  end

  def update_event_redmine_issue_url url
    connect
    #get event JSON from Redis
    json = @redis.hget('events:' + handler.host_name, handler.check_name)
    #parse JSON to hash
    data = JSON.parse(json)
    #extend hash with custom_data.redmine_issue_url
    data['custom_data']['redmine_issue_url'] = url
    #save serialized hash as JSON back to Redis 
    @redis.hset('events:' + handler.host_name, handler.check_name, data.to_json)
    disconnect
    return true
  end


private
  def connect
    conf = handler.settings['redis']
    @redis = Redis.new(conf)
  end
  
  def disconnect
    @redis.quit
  end
end