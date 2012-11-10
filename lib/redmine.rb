class Redmine
  attr_reader :handler

  def initialize h
    if not h.class == VirtualmasterHandler
      raise StandardError, "First argument must be instance of VirtualmasterHandler"
    end

    if not h.settings['virtualmaster'].keys.include?('redmine')
      raise StandardError, 'Sensu handler config have to contain "redmine" section'
    end
    @handler = h
  end

  def create_issue issue
    host = handler.settings['virtualmaster']['redmine']['host']
    key = handler.settings['virtualmaster']['redmine']['key']
    agent = handler.settings['virtualmaster']['user-agent']

    headers = {
     'Accept' => 'application/json',
     'Content-Type' => 'application/json',
     'User-Agent'=> agent
    }

    url = host + "/issue.json?key=#{key}"
    
    limit = handler.settings['virtualmaster']['redmine']['timeout']
    limit = 1 if limit.nil?
    limit = limit.to_i

    uri = URI.parse(url)
    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = limit
      http.open_timeout = limit
      resp = http.post(uri.path + "?"+uri.query, issue.to_json, headers)
    rescue Timeout::Error
      raise StandardError, "Redmine timeouted after #{limit} seconds."
    rescue SocketError
      raise StandardError, "Redmie is down or not reachable"
    rescue StandardError => e
      if e.message == "Errno::ECONNREFUSED"
        raise StandardError, "Redmine is down or not reachable"
      else
        raise e
      end
    end

    resp_text = resp.body
    
    if not resp.code == "201"
      return false
    else
      return true
    end
  end
end