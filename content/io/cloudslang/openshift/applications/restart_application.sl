#   Copyright 2023 Open Text
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
#! @description: Performs a REST API call in order to restart an existing and running RedHat OpenShift Online application.
#!
#! @input host: RedHat OpenShift Online host
#! @input username: Optional - RedHat OpenShift Online username
#!                  example: 'someone@mailprovider.com'
#! @input password: Optional - RedHat OpenShift Online password used for authentication
#! @input proxy_host: Optional - proxy server used to access RedHat OpenShift Online web site
#! @input proxy_port: Optional - proxy server port
#!                    default: '8080'
#! @input proxy_username: Optional - user name used when connecting to proxy
#! @input proxy_password: Optional - proxy server password associated with <proxy_username> input value
#! @input domain: name of RedHat OpenShift Online domain the application belongs to
#! @input application_name: RedHat OpenShift Online application name that will be restarted
#!
#! @output return_result: response of the operation in case of success, error message otherwise
#! @output error_message: return_result if status_code is not '200'
#! @output return_code: '0' if success, '-1' otherwise
#! @output status_code: code returned by the operation
#!
#! @result SUCCESS: Openshift application restarted successfully
#! @result FAILURE: There was an error while trying to restart the Openshift application
#!!#
########################################################################################################################

namespace: io.cloudslang.openshift.applications

imports:
  rest: io.cloudslang.base.http

flow:
  name: restart_application

  inputs:
    - host
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
    - domain
    - application_name

  workflow:
    - restart_app:
        do:
          rest.http_client_post:
            - url: ${'https://' + host + '/broker/rest/domains/' + domain + '/applications/' + application_name + '/events'}
            - username
            - password
            - proxy_host
            - proxy_port
            - proxy_username
            - proxy_password
            - content_type: 'application/json'
            - body: '{"event":"restart"}'
            - headers: 'Accept: application/json'
        publish:
          - return_result
          - error_message
          - return_code
          - status_code

  outputs:
    - return_result
    - error_message
    - return_code
    - status_code
