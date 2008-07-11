#!/usr/bin/env ruby

Codes = ["Informational 1xx", "100 Continue", "101 Switching Protocols", "Successful 2xx", "200 OK", "201 Created", "202 Accepted", "203 Non-Authoritative Information", "204 No Content", "205 Reset Content", "206 Partial Content", "Redirection 3xx", "300 Multiple Choices", "301 Moved Permanently", "302 Found", "303 See Other", "304 Not Modified", "305 Use Proxy", "306 (Unused)", "307 Temporary Redirect", "Client Error 4xx", "400 Bad Request", "401 Unauthorized", "402 Payment Required", "403 Forbidden", "404 Not Found", "405 Method Not Allowed", "406 Not Acceptable", "407 Proxy Authentication Required", "408 Request Timeout", "409 Conflict", "410 Gone", "411 Length Required", "412 Precondition Failed", "413 Request Entity Too Large", "414 Request-URI Too Long", "415 Unsupported Media Type", "416 Requested Range Not Satisfiable", "417 Expectation Failed", "Server Error 5xx", "500 Internal Server Error", "501 Not Implemented", "502 Bad Gateway", "503 Service Unavailable", "504 Gateway Timeout", "505 HTTP Version Not Supported"]
Codes.each do |c|
  if m = c.match(/^(\d\d\d) ([A-Za-z0-9\-\s]+)/)
    long_name = m[2]
    meth_name = long_name.downcase.gsub(/[\s-]/, '_')
    code_name = m[1]
    
    puts "'#{code_name}' => 'on_#{meth_name}',"
# alias :on_#{long_name} :on_#{code_name}

  elsif c =~ /\dxx$/
    long_name, class_number = c[0..-4], c[-3..-1]
  end
end