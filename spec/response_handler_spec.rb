require File.dirname(__FILE__) + '/spec_helper.rb'

# Making mocking up HTTP responses easy.
def mock_response(status_code, body_str='')
  response_class = Net::HTTPResponse::CODE_TO_OBJ[status_code.to_s]
  response = response_class.new('1.1', status_code.to_s, '')
  response.instance_eval("def body; #{body_str.inspect}; end")
  response
end

class EmptyHandler < HandleHttp::ResponseHandler
  attr_reader :result
end

class Simple200Handler < EmptyHandler
  def on_200(response, extras)
    @result = "Yay"
  end
end

class Simple2xxHandler < EmptyHandler
  def on_2xx(response, extras)
    @result = "Hello"
  end
end

class Simple200And2xxHandler < Simple200Handler
  def on_2xx(response, extras)
    @result = "Should not get here"
  end
end

describe HandleHttp::ResponseHandler do
  it "should run the callback for 200 properly" do
    sh = Simple200Handler.new(mock_response('200'))
    sh.result.should eql("Yay")
  end
  
  it "should run the status class callback for 200 if the specific status code callback doesn't exist" do
    sh = Simple2xxHandler.new(mock_response('200'))
    sh.result.should eql("Hello")
  end
  
  it "should run a specific code callback before going to the status class callback" do
    sh = Simple200And2xxHandler.new(mock_response('200'))
    sh.result.should eql("Yay")
  end
  
  it "should raise an error if the status code is unhandled" do
    proc { EmptyHandler.new(mock_response('100')) }.should raise_error(HandleHttp::UnhandledInformationalStatusError)
    proc { EmptyHandler.new(mock_response('200')) }.should raise_error(HandleHttp::UnhandledSuccessfulStatusError)
    proc { EmptyHandler.new(mock_response('300')) }.should raise_error(HandleHttp::UnhandledRedirectionStatusError)
    proc { EmptyHandler.new(mock_response('400')) }.should raise_error(HandleHttp::UnhandledClientErrorStatusError)
    proc { EmptyHandler.new(mock_response('500')) }.should raise_error(HandleHttp::UnhandledServerErrorStatusError)
  end
  
  it "should accept and pass through extra data to the callback methods" do
    class ExtrasHandler < EmptyHandler
      def on_200(request, extras)
        @result = extras[:request]
      end
    end
    sh = ExtrasHandler.new(mock_response('200'), :request => 'fakerequest')
    sh.result.should eql('fakerequest')
  end
end
