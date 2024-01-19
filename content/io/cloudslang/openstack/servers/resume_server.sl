#   Copyright 2024 Open Text
#   This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
########################################################################################################################
#!!
#! @description: Resumes a SUSPENDED server and changes its status to ACTIVE.
#!
#! @input host: OpenStack host
#! @input identity_port: Optional - port used for OpenStack authentication
#!                       Default: '5000'
#! @input compute_port: Optional - port used for OpenStack computations
#!                      Default: '8774'
#! @input tenant_name: name of OpenStack project that contains server (instance) to be resumed
#! @input server_id: ID of server (instance) to be resumed
#! @input username: Optional - username used for URL authentication; for NTLM authentication
#!                  Format: 'domain\user'
#! @input password: Optional - password used for URL authentication
#! @input proxy_host: Optional - proxy server used to access OpenStack services
#! @input proxy_port: Optional - proxy server port used to access OpenStack services
#!                    Default: '8080'
#! @input proxy_username: Optional - user name used when connecting to proxy
#! @input proxy_password: Optional - proxy server password associated with <proxy_username> input value
#! @input trust_keystore: Optional - the pathname of the Java TrustStore file. This contains certificates from other
#!                        parties that you expect to communicate with, or from Certificate Authorities that you trust to
#!                        identify other parties.  If the protocol (specified by the 'url') is not 'https' or if
#!                        trustAllRoots is 'true' this input is ignored.
#!                        Default value: ..JAVA_HOME/java/lib/security/cacerts
#!                        Format: Java KeyStore (JKS)
#! @input trust_password: Optional - the password associated with the TrustStore file.
#!                        If trust_all_roots is false and trustKeystore is empty,
#!                        trustPassword default will be supplied.
#!                        Default value: ''
#! @input keystore: Optional - the pathname of the Java KeyStore file.
#!                  You only need this if the server requires client authentication.
#!                  If the protocol (specified by the 'url') is not 'https' or if trust_all_roots
#!                  is 'true' this input is ignored.
#!                  Default value: ..JAVA_HOME/java/lib/security/cacerts
#!                  Format: Java KeyStore (JKS)
#! @input keystore_password: Optional - the password associated with the KeyStore file.
#!                           If trust_all_reoots is false and keystore
#!                           is empty, keystorePassword default will be supplied.
#!                           Default value: ''
#!
#! @output return_result: response of operation in case of success, error message otherwise
#! @output error_message: return_result if statusCode is not '202'
#! @output return_code: '0' if success, '-1' otherwise
#! @output status_code: code returned by operation
#!
#! @result SUCCESS: OpenStack server (instance) was successfully suspended
#! @result GET_AUTHENTICATION_FAILURE: authentication step fail
#! @result GET_AUTHENTICATION_TOKEN_FAILURE: authentication token cannot be obtained from authentication step response
#! @result GET_TENANT_ID_FAILURE: tenant_id corresponding to tenant_name cannot be obtained from authentication
#!                                step response
#! @result RESUME_SERVER_FAILURE: OpenStack server (instance) cannot be resumed
#!!#
########################################################################################################################

namespace: io.cloudslang.openstack.servers

imports:
  rest: io.cloudslang.base.http
  openstack: io.cloudslang.openstack

flow:
  name: resume_server

  inputs:
    - host
    - identity_port: '5000'
    - compute_port: '8774'
    - tenant_name
    - server_id
    - username:
        required: false
    - password:
        required: false
        sensitive: true
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
    - trust_keystore:
        default: ${get_sp('io.cloudslang.openstack.trust_keystore')}
        required: false
    - trust_password:
        default: ${get_sp('io.cloudslang.openstack.trust_password')}
        required: false
        sensitive: true
    - keystore:
        default: ${get_sp('io.cloudslang.openstack.keystore')}
        required: false
    - keystore_password:
        default: ${get_sp('io.cloudslang.openstack.keystore_password')}
        required: false
        sensitive: true

  workflow:
    - authentication:
        do:
          openstack.get_authentication_flow:
            - host
            - identity_port
            - username
            - password
            - tenant_name
            - proxy_host
            - proxy_port
            - proxy_username
            - proxy_password
        publish:
          - return_result
          - error_message
          - token
          - tenant_id
        navigate:
          - SUCCESS: resume_server
          - GET_AUTHENTICATION_FAILURE: GET_AUTHENTICATION_FAILURE
          - GET_AUTHENTICATION_TOKEN_FAILURE: GET_AUTHENTICATION_TOKEN_FAILURE
          - GET_TENANT_ID_FAILURE: GET_TENANT_ID_FAILURE

    - resume_server:
        do:
          rest.http_client_post:
            - url: ${'http://' + host + ':' + compute_port + '/v2/' + tenant_id + '/servers/'+ server_id + '/action'}
            - proxy_host
            - proxy_port
            - proxy_username
            - proxy_password
            - trust_all_roots: "false"
            - x_509_hostname_verifier: "strict"
            - trust_keystore
            - trust_password
            - keystore
            - keystore_password
            - headers: ${'X-AUTH-TOKEN:' + token}
            - body: '{"resume":null}'
            - content_type: 'application/json'
        publish:
          - return_result
          - error_message
          - return_code
          - status_code
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: RESUME_SERVER_FAILURE

  outputs:
    - return_result
    - error_message
    - return_code
    - status_code

  results:
    - SUCCESS
    - GET_AUTHENTICATION_FAILURE
    - GET_AUTHENTICATION_TOKEN_FAILURE
    - GET_TENANT_ID_FAILURE
    - RESUME_SERVER_FAILURE
