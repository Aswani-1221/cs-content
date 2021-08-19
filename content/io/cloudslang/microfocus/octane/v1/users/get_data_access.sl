########################################################################################################################
#!!
#! @description: This flow gets users` data access level
#!
#! @input url: The URL of the host running Octane. The format should be <protocol>://host:port.
#! @input auth_type: Type of authentication used to execute the request on the target server.Valid: 'basic', 'form', 'springForm', 'digest', 'ntlm', 'kerberos', 'anonymous' (no authentication)Default: 'anonymous'
#! @input shared_spaces: Shared space Id
#! @input workspaces: Workspace Id
#! @input proxy_host: The proxy server used to access the web site.
#! @input proxy_port: The proxy server port. Default value: 8080. Valid values: -1, and positive integer values. When the value is '-1' the default port of the scheme, specified in the 'proxyHost', will be used.
#! @input proxy_username: The user name used when connecting to the proxy. The "authType" input will be used to choose authentication type. The "Basic" and "Digest" proxy auth type are supported.
#! @input proxy_password: The proxy server password associated with the proxyUsername input value.
#! @input trust_all_roots: Specifies whether to enable weak security over TSL. A certificate is trusted even if no trusted certification authority issued it.
#! @input x_509_hostname_verifier: Specifies the way the server hostname must match a domain name in the subject's Common Name (CN) or subjectAltName field of the X.509 certificate. The hostname verification system prevents communication with other hosts other than the ones you intended. This is done by checking that the hostname is in the subject alternative name extension of the certificate. This system is designed to ensure that, if an attacker (Man-In-The-Middle) redirects traffic to his machine, the client will not accept the connection. If you set this input to "allow_all", this verification is ignored and you become vulnerable to security attacks. For the value "browser_compatible" the hostname verifier works the same way as Curl and Firefox. The hostname must match either the first CN, or any of the subject-alts. A wildcard can occur in the CN, and in any of the subject-alts. The only difference between "browser_compatible" and "strict" is that a wildcard (such as "*.foo.com") with "browser_compatible" matches all subdomains, including "a.b.foo.com". From the security perspective, to provide protection against possible Man-In-The-Middle attacks, we strongly recommend to use "strict" option.
#! @input trust_keystore: The pathname of the Java TrustStore file. This contains certificates from other parties that you expect to communicate with, or from Certificate Authorities that you trust to identify other parties. If the protocol (specified by the URL) is not HTTPS or if trustAllRoots is "true" this input is ignored.
#! @input trust_password: The password associated with the TrustStore file. If trustAllRoots is false and trustKeystore is empty, trustPassword default will be supplied
#! @input connect_timeout: The time to wait for a connection to be established, in seconds. A timeout value of 0 represents an infinite timeout.
#! @input socket_timeout: The timeout for waiting for data (a maximum period inactivity between two consecutive data packets), in seconds. A socketTimeout value of 0 represents an infinite timeout.
#! @input header: List containing the headers to use for the request separated by new line (CRLF).Header name - value pair will be separated by ":"Format: According to HTTP standard for headers (RFC 2616)Example: 'Accept:text/plain'
#! @input query_params: List containing query parameters to append to the URL.Examples: 'parameterName1=parameterValue1&parameterName2=parameterValue2;'
#!
#! @output return_result: Contains a human readable message describing the status of the Octane Action.
#! @output return_code: The returnCode of the operation: 0 for success, -1 for failure.
#! @output status_code: The HTTP status code.
#! @output response_headers: The list containing the headers of the response message, separated by newline.
#! @output error_message: In case of success response, this result is empty. In case of failure response, this result contains the stack trace of the runtime exception.
#! @output data: The list containing all the user with data access
#! @output totat_count: The total number
#!!#
########################################################################################################################
namespace: io.cloudslang.microfocus.octane.v1.users
flow:
  name: get_data_access
  inputs:
    - url
    - auth_type:
        required: false
    - shared_spaces:
        required: true
    - workspaces:
        required: true
    - proxy_host:
        required: false
    - proxy_port:
        default: '8080'
        required: false
    - proxy_username:
        required: false
    - proxy_password:
        required: false
        sensitive: true
    - trust_all_roots:
        default: 'false'
        required: false
    - x_509_hostname_verifier:
        default: strict
        required: false
    - trust_keystore:
        required: false
    - trust_password:
        required: false
        sensitive: true
    - connect_timeout:
        required: false
    - socket_timeout:
        required: false
    - header
    - query_params:
        required: false
  workflow:
    - get_data_access:
        do:
          io.cloudslang.base.http.http_client_get:
            - url: "${url+'/api/shared_spaces/'+shared_spaces+'/workspaces/'+workspaces+'/workspace_users?fields=data_access,%20data_access_enabled,%20name,first_name,%20last_name'}"
            - auth_type: '${auth_type}'
            - headers: '${header}'
        publish:
          - return_result
          - error_message
          - return_code
          - status_code
          - response_headers
        navigate:
          - SUCCESS: parse_return_result
          - FAILURE: on_failure
    - parse_return_result:
        do:
          io.cloudslang.microfocus.octane.v1.utils.parse_return_result:
            - text: '${return_result}'
        publish:
          - data
          - total_count
        navigate:
          - SUCCESS: SUCCESS
  outputs:
    - return_result: '${return_result}'
    - return_code: '${return_code}'
    - status_code: '${status_code}'
    - response_headers: '${response_headers}'
    - error_message: '${error_message}'
    - data: '${data}'
    - totat_count: '${total_count}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_data_access:
        x: 100
        'y': 150
      parse_return_result:
        x: 400
        'y': 150
        navigate:
          9fc43cb4-5488-9ad8-c432-acf8f0634216:
            targetId: 50034024-01ee-356b-80f9-05b47b422713
            port: SUCCESS
    results:
      SUCCESS:
        50034024-01ee-356b-80f9-05b47b422713:
          x: 700
          'y': 150
