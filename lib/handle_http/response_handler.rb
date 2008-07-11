#!/usr/bin/env ruby
require 'handle_http/errors'
require 'handle_http/callbacks'

module HandleHttp
  class ResponseHandler
    attr_reader :response, :extras
    
    def initialize(response, extras={})
      @response = response
      @extras = extras
      http_callback
    end

    def http_callback
      if callback_method = find_http_callback
        return send_http_callback(callback_method)
      end
      
      # Give up and throw the proper error
      raise StatusCodeToErrorMap[response.code[0,1]].new(response)
    end
    
    def find_http_callback
      # If the object specifically handles this status code 
      find_callback_or_alternate_callback(response.code) ||
      
      # If we don't handle the status code specifically, but do handle the 
      # entire class of status codes (i.e. '1xx', '2xx', etc.).
      find_callback_or_alternate_callback(response.code[0,1]+'xx')
    end
    
    def find_callback_or_alternate_callback(callback_id)
      meth = "on_#{callback_id}"
      return meth if respond_to? meth
      
      alternate_callbacks[callback_id].find{|m| respond_to? m }
    end
    
    # This enables derived classes to easily change what happens when the 
    # appropriate callback method is found, including what arguments are passed
    # to the callback method. This makes things pretty cool.
    def send_http_callback(callback_method)
      send(callback_method, response, extras)
    end
    
    # Meta magic to ensure that inheriting objects do not change its ancestors'
    # alternate callbacks when it modifies its own.
    def self.alternate_callbacks
      @alternate_callbacks ||= HandleHttp::AlternateCallbacks
    end

    def alternate_callbacks
      self.class.alternate_callbacks
    end
    
    def self.inherited(subclass)
      subclass.instance_variable_set(:@alternate_callbacks, Marshal.load(Marshal.dump(alternate_callbacks)))
    end
  end
end