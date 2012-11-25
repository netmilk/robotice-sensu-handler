def handler
  VirtualmasterHandler.new
end

def event_mock(name)
  event_path = File.join(File.dirname(__FILE__), 'responses','events',"#{name}.json")
  f = File.open(event_path,'r')
  f
end

# at_exit is monkeypatch to avoid Handler::Sensu hang
# we need to call that overrriden block manually in each test
def handle event_data
  handler = VirtualmasterHandler.new
  capture_stdout{
  handler.read_event(event_data)
    handler.filter
    handler.handle
  }
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

def capture_stdout(&block)
  original_stdout = $stdout
  $stdout = fake = StringIO.new
  begin
    yield
  ensure
    $stdout = original_stdout
  end
  fake.string
end

