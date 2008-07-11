#!/usr/bin/env ruby
module HandleHttp
    
    class UnhandledStatusError < StandardError
      attr_reader :http_response
      
      def initialize(http_response)
        @http_response = http_response
        super("Received unhandled status code #{http_response.code.inspect}.")
      end
    end
    
    # 1xx
    class UnhandledInformationalStatusError < UnhandledStatusError; end
    
    # 2xx
    class UnhandledSuccessfulStatusError    < UnhandledStatusError; end
    
    # 3xx
    class UnhandledRedirectionStatusError   < UnhandledStatusError; end
    
    # 4xx
    class UnhandledClientErrorStatusError   < UnhandledStatusError; end
    
    # 5xx
    class UnhandledServerErrorStatusError   < UnhandledStatusError; end
    
    StatusCodeToErrorMap = {
      "1" => UnhandledInformationalStatusError,
      "2" => UnhandledSuccessfulStatusError,
      "3" => UnhandledRedirectionStatusError,
      "4" => UnhandledClientErrorStatusError,
      "5" => UnhandledServerErrorStatusError
    }
    
end