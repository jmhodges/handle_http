require 'handle_http/errors'
module HandleHttp
  # The left-most method name is the first one checked. 
  # The right-most is the last checked.
  AlternateCallbacks = {
    # Status code classes
    '1xx' => ['on_informational'],
    '2xx' => ['on_successful'],
    '3xx' => ['on_redirection',   'on_error'],
    '4xx' => ['on_client_error',  'on_error'],
    '5xx' => ['on_server_error',  'on_error'],
    
    # Informational
    '100' => ['on_continue'],
    '101' => ['on_switching_protocols'],
    
    # Successful
    '200' => ['on_ok'],
    '201' => ['on_created'],
    '202' => ['on_accepted'],
    '203' => ['on_non_authoritative_information'],
    '204' => ['on_no_content'],
    '205' => ['on_reset_content'],
    '206' => ['on_partial_content'],
    
    # Redirections
    '300' => ['on_multiple_choices'],
    '301' => ['on_moved_permanently'],
    '302' => ['on_found'],
    '303' => ['on_see_other'],
    '304' => ['on_not_modified'],
    '305' => ['on_use_proxy'],
    '307' => ['on_temporary_redirect'],
    
    # Client Errors
    '400' => ['on_bad_request'],
    '401' => ['on_unauthorized'],
    '402' => ['on_payment_required'],
    '403' => ['on_forbidden'],
    '404' => ['on_not_found'],
    '405' => ['on_method_not_allowed'],
    '406' => ['on_not_acceptable'],
    '407' => ['on_proxy_authentication_required'],
    '408' => ['on_request_timeout'],
    '409' => ['on_conflict'],
    '410' => ['on_gone'],
    '411' => ['on_length_required'],
    '412' => ['on_precondition_failed'],
    '413' => ['on_request_entity_too_large'],
    '414' => ['on_request_uri_too_long'],
    '415' => ['on_unsupported_media_type'],
    '416' => ['on_requested_range_not_satisfiable'],
    '417' => ['on_expectation_failed'],
    
    # Server Errors
    '500' => ['on_internal_server_error'],
    '501' => ['on_not_implemented'],
    '502' => ['on_bad_gateway'],
    '503' => ['on_service_unavailable'],
    '504' => ['on_gateway_timeout'],
    '505' => ['on_http_version_not_supported']
  }
end