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
  
  
  it "should handle 1xx class status codes with on_1xx or on_informational and use on_1xx if both are defined" do
    class InfoPrettyHandler < EmptyHandler
      def on_informational(response, extras)
        @result = "pretty"
      end
    end
    
    class InfoHandler < InfoPrettyHandler
      def on_1xx(result, extras)
        @result = "number"
      end
    end
    sh = InfoHandler.new(mock_response('101'))
    sh.result.should eql('number')
    
    sh = InfoPrettyHandler.new(mock_response('101'))
    sh.result.should eql('pretty')
  end
  
  it "should handle 2xx class status codes with on_2xx or on_successful and use on_2xx if both are defined" do
    class SuccessPrettyHandler < EmptyHandler
      def on_successful(response, extras)
        @result = "pretty"
      end
    end
    
    class SuccessHandler < SuccessPrettyHandler
      def on_2xx(result, extras)
        @result = "number"
      end
    end
    sh = SuccessHandler.new(mock_response('202'))
    sh.result.should eql('number')
    
    sh = SuccessPrettyHandler.new(mock_response('202'))
    sh.result.should eql('pretty')
  end
  
  it "should handle 3xx class status codes with on_3xx or on_redirection and use on_3xx if both are defined" do
    class RedirectPrettyHandler < EmptyHandler
      def on_redirection(response, extras)
        @result = "pretty"
      end
    end
    
    class RedirectHandler < RedirectPrettyHandler
      def on_3xx(response, extras)
        @result = "number"
      end
    end
    
    sh = RedirectHandler.new(mock_response('301'))
    sh.result.should eql("number")
    
    sh = RedirectPrettyHandler.new(mock_response('301'))
    sh.result.should eql("pretty")
  end
  
  it "should handle 4xx class status codes with on_4xx or on_client_error and use on_4xx if both are defined" do
    class ClientErrPrettyHandler < EmptyHandler
      def on_client_error(response, extras)
        @result = "pretty"
      end
    end
    
    class ClientErrHandler < ClientErrPrettyHandler
      def on_4xx(result, extras)
        @result = "number"
      end
    end
    
    sh = ClientErrHandler.new(mock_response('404'))
    sh.result.should eql('number')
    
    sh = ClientErrPrettyHandler.new(mock_response('404'))
    sh.result.should eql('pretty')
  end
  
  it "should handle 5xx class status codes with on_5xx or on_server_error and use on_5xx if both are defined" do
    class ServerErrPrettyHandler < EmptyHandler
      def on_server_error(response, extras)
        @result = "pretty"
      end
    end
    
    class ServerErrHandler < ServerErrPrettyHandler
      def on_5xx(result, extras)
        @result = "number"
      end
    end
    
    sh = ServerErrHandler.new(mock_response('503'))
    sh.result.should eql('number')
    
    sh = ServerErrPrettyHandler.new(mock_response('503'))
    sh.result.should eql('pretty')
  end
  
  it "should handle 3xx, 4xx, and 5xx status codes with on_error unless the specific status code or status class callback is defined" do
    class OnErrorHandler < EmptyHandler
      def on_error(response, extras)
        @result = "on_error"
      end
    end
    
    class ChainRedirectErrHandler < OnErrorHandler
      def on_302(result, extras); @result = "302"; end
    end
    
    class ChainClientErrHandler < OnErrorHandler
      def on_402(result, extras); @result = "402"; end
    end
    
    class ChainServerErrHandler < OnErrorHandler
      def on_502(result, extras); @result = "502"; end
    end
    
    ch = ChainRedirectErrHandler.new(mock_response('304'))
    ch.result.should eql("on_error")
    
    ch = ChainRedirectErrHandler.new(mock_response('302'))
    ch.result.should eql("302")
    
    ch = ChainClientErrHandler.new(mock_response('404'))
    ch.result.should eql("on_error")
    
    ch = ChainClientErrHandler.new(mock_response('402'))
    ch.result.should eql("402")
    
    ch = ChainServerErrHandler.new(mock_response('504'))
    ch.result.should eql("on_error")
    
    ch = ChainServerErrHandler.new(mock_response('502'))
    ch.result.should eql("502")
    
  end
  
  it "should allow an inheriting object to change the alternate callback method names without changing the parent" do
    class AncestorHandler < EmptyHandler
      def on_foobar(request, extras)
        @result = "ancestor"
      end
    end
    
    class InheritingHandler < AncestorHandler
      alternate_callbacks["2xx"] << "on_foobar"
      def on_foobar(request, extras)
        @result = "inheriting"
      end 
    end

    proc { AncestorHandler.new(mock_response('200')) }.should raise_error(HandleHttp::UnhandledSuccessfulStatusError)
    ih = InheritingHandler.new(mock_response('200'))
    ih.result.should eql("inheriting")
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
