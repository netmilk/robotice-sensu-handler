class Foreman
  attr_reader :handler
  
  def initialize handler
    if not handler.class == VirtualmasterHandler
      raise StandardError, "First argument must be instance of VirtualmasterHandler"
    end
    
    if not handler.settings['virtualmaster'].keys.include?('foreman')
      raise StandardError, 'Handler config have to contain "foreman" section'
    end
    @handler = handler    
  end
  
  def query_host hostname
    host = handler.settings['virtualmaster']['foreman']['host']
    url = host + "/node/#{hostname}?format=yml"
    
    limit = settings['virtualmaster']['foreman']['timeout']
    limit = 1 if limit.nil?
    limit = limit.to_i

    uri = URI.parse(url)
    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = limit
      http.open_timeout = limit
      resp = http.get(uri.path + "?" + uri.query)
    rescue Timeout::Error
      raise StandardError, "Foreman timeouted after #{limit} seconds."
    rescue SocketError
      raise StandardError, "Foreman is down or not reachable"
    rescue StandardError => e
      if e.message == "Errno::ECONNREFUSED"
        raise StandardError, "Foreman is down or not reachable"
      else
        raise e
      end
    end

    resp_text = resp.body
    
    if resp.code == "404"
      raise StandardError, "Foreman does not know host '#{hostname}'"
    end
    
    response_hash = YAML::load(resp_text)

    if response_hash['parameters'].nil?
      raise "Host '#{hostname}' has not required data in Foreman"
    end

    result = {
      'redmine_project_url' => response_hash['parameters']['redmine_project_url'],
      'redmine_priority' => response_hash['parameters']['redmine_priority']
    }
    
    if result['redmine_project_url'].nil? or result['redmine_priority'].nil?
      raise "Host '#{hostname}' has not required data in Foreman"
    end

    result
    
  end
end