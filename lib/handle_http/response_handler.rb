#!/usr/bin/env ruby
require 'handle_http/errors'

module HandleHttp
  class ResponseHandler
    def initialize(response, extras={})
      http_callback(response, extras)
    end

    def http_callback(response, extras)
      # The first returns a method name if the object specifically handles the 
      # response's status code. The second returns a method name if we don't 
      # handle the status code specifically, but do handle the entire class of
      # status codes (i.e. '1xx', '2xx', etc.).

      callback_method = find_http_callback(response.code) || 
                        find_http_callback(response.code[0,1]+'xx')
      
      if callback_method
        return send_http_callback(callback_method)
      end
      
      # Give up and throw the proper error
      raise StatusCodeToErrorMap[response.code[0,1]].new(response)
    end
    
    def find_http_callback(http_callback_meth)
      meth = "on_#{http_callback_meth}"
      return meth if respond_to? meth
    end
    
    # This enables derived classes to easily change what happens when the 
    # appropriate callback method is found, including what arguments are passed
    # to the callback method. This makes things pretty cool.
    def send_http_callback(callback_method)
      send(callback_method, response, extras)
    end
  end
end