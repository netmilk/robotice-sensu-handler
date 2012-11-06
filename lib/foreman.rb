require 'yaml'

class Foreman
  attr_reader :handler
  
  def initialize h
    if not h.class == VirtualmasterHandler
      raise StandardError, "First argument must be instance of VirtualmasterHandler"
    end
    
    if not h.settings['virtualmaster'].keys.include?('foreman')
      raise StandardError, 'Sensu handler config have to contain "foreman" section'
    end
    @handler = h
  end
  
  def query_host hostname
    host = handler.settings['virtualmaster']['foreman']['host']
    url = host + "/node/#{hostname}?format=yml"
    
    limit = handler.settings['virtualmaster']['foreman']['timeout']
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
      return false
    end
    
    response_hash = YAML::load(resp_text)
    
    if response_hash['parameters'].nil?
      return nil
    else
      return result = {
        'redmine_url' => response_hash['parameters']['redmine_url'],
        'redmine_priority' => response_hash['parameters']['redmine_priority'],
        'redmine_project' => response_hash['parameters']['redmine_project']
      }
    end
  end
end