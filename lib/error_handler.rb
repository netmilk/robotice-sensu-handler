class ErrorHandler
  attr_reader :message 
  
  def initialize(mes)
    @message = mes
    self.handle
  end
  
  def handle
    #TODO log, notify
  end
end
