class ErrorHandler
  attr_reader :message 
  
  def initialize(mes)
    @message = mes
    self.notify
  end
  
  def notify
  
  end
end
