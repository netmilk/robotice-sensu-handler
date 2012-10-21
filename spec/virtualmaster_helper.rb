def handler
  VirtualmasterHandler.new
end

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
  handler
end

## call it: response_mock foreman/valid_response
def mock_response relative_path
   path = File.join(File.dirname(__FILE__), 'responses', relative_path)
   File.open(path,'r')
end

def settings
  s = {}
  ENV['SENSU_CONFIG_FILES'].split(":").each do |file|
    s.merge! JSON.parse(File.open(file,'r').read)
  end
  s
end
