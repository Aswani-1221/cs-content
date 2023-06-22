#   (c) Copyright 2023 Micro Focus, L.P.
#   All rights reserved. This program and the accompanying materials
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
#! @description: The operation is used to fetch all the suppressions within a particular subscription.
#!
#! @input auth_token: The authorization token for azure cloud.
#! @input subscription_id: GUID which uniquely identify Microsoft Azure subscription. The subscription ID forms part of
#!                         the URI for every service call.
#! @input proxy_host: Optional - Proxy server used to access the web site.
#! @input proxy_port: Optional - Proxy server port.
#!                    Default: '8080'.
#! @input proxy_username: Optional - Username used when connecting to the proxy.
#! @input proxy_password: Optional - Proxy server password associated with the <proxy_username> input value.
#! @input trust_keystore: Optional - the pathname of the Java TrustStore file. This contains certificates from
#!                        other parties that you expect to communicate with, or from Certificate Authorities that
#!                        you trust to identify other parties.  If the protocol (specified by the 'url') is not
#!                        'https' or if trust_all_roots is 'true' this input is ignored.
#!                        Default value: ..JAVA_HOME/java/lib/security/cacerts
#!                        Format: Java KeyStore (JKS)
#! @input trust_password: Optional - the password associated with the trust_keystore file. If trust_all_roots is false
#!                        and trust_keystore is empty, trust_password default will be supplied.
#! @input trust_all_roots: Optional - Specifies whether to enable weak security over SSL.
#!                         Default: 'false'.
#! @input x_509_hostname_verifier: Optional - specifies the way the server hostname must match a domain name in
#!                                 the subject's Common Name (CN) or subjectAltName field of the X.509 certificate
#!                                 Valid: 'strict', 'browser_compatible', 'allow_all' - Default: 'allow_all'
#!                                 Default: 'strict'
#! @input connect_timeout: Optional - time in seconds to wait for a connection to be established
#!                         Default: '0' (infinite)
#! @input socket_timeout: Optional - time in seconds to wait for data to be retrieved.
#!                        Default: '0' (infinite)
#! @input worker_group: Optional - A worker group is a logical collection of workers. A worker may belong to more one group simultaneously.
#!                      Default: 'RAS_Operator_Path'.
#!
#! @output return_result: json response with list of suppressions
#! @output status_code: 200 if request completed successfully, others in case something went wrong.
#! @output error_message: Error in fetching suppressions details.
#! @output postponed_resource_id: The fully qualified Azure Resource Manager identifier of the resource to which the recommendation applies.
#! @output dismissed_resource_id: The fully qualified Azure Resource Manager identifier of the resource to which the recommendation applies.
#! @output postponed_recommendation_id: The postponed recommendation ID.
#! @output dismissed_recommendation_id: The dismissed recommendation ID.
#! @output json: json response with list of suppressions
#!
#! @result FAILURE: Error in fetching list of suppressions.
#! @result SUCCESS: Successfully retrieved the list of suppressions.
#!!#
########################################################################################################################
namespace: io.cloudslang.microsoft.azure.advisor.recommendations.suppressions
flow:
  name: list_suppressions
  inputs:
    - auth_token:
        sensitive: true
    - subscription_id
    - proxy_host:
        required: false
    - proxy_port:
        required: false
    - proxy_username:
        required: false
    - proxy_password:
        required: false
        sensitive: true
    - trust_keystore:
        required: false
    - trust_password:
        required: false
        sensitive: true
    - trust_all_roots:
        default: 'false'
        required: false
    - x_509_hostname_verifier:
        default: strict
        required: false
    - connect_timeout:
        default: '10'
        required: false
    - socket_timeout:
        default: '0'
        required: false
    - worker_group:
        default: RAS_Operator_Path
        required: false
  workflow:
    - api_call_to_list_recommendations:
        worker_group: "${get('worker_group', 'RAS_Operator_Path')}"
        do:
          io.cloudslang.base.http.http_client_action:
            - url: "${'https://management.azure.com/subscriptions/'+subscription_id+'/providers/Microsoft.Advisor/suppressions?api-version=2023-01-01'}"
            - auth_type: anonymous
            - username
            - password
            - tls_version
            - allowed_cyphers
            - proxy_host: '${proxy_host}'
            - proxy_port: '${proxy_port}'
            - proxy_username
            - proxy_password
            - trust_all_roots: '${trust_all_roots}'
            - x_509_hostname_verifier: '${x_509_hostname_verifier}'
            - trust_keystore
            - trust_password
            - keystore
            - keystore_password
            - execution_timeout
            - connect_timeout: '${connect_timeout}'
            - socket_timeout: '${socket_timeout}'
            - keep_alive
            - connections_max_per_route
            - connections_max_total
            - headers: "${'Authorization: ' + auth_token}"
            - query_params
            - content_type
            - method: GET
            - request_character_set: utf-8
            - response_character_set: utf-8
        publish:
          - error_message
          - status_code
          - json: '${return_result}'
        navigate:
          - SUCCESS: extract_resource_id
          - FAILURE: on_failure
    - set_success_message:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.base.utils.do_nothing:
            - message: Successfully retrieved the list of suppressions.
        publish:
          - output: '${message}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - extract_dismissed_recommendation_id:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.microsoft.azure.advisor.recommendations.suppressions.utils.extract_recommendation_id:
            - resource_id_list: '${dismissed_resource_id}'
        publish:
          - dismissed_recommendation_id: '${return_result}'
        navigate:
          - SUCCESS: extract_postponed_recommendation_id
    - extract_postponed_recommendation_id:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.microsoft.azure.advisor.recommendations.suppressions.utils.extract_recommendation_id:
            - resource_id_list: '${postponed_resource_id}'
        publish:
          - postponed_recommendation_id: '${return_result}'
        navigate:
          - SUCCESS: set_success_message
    - extract_resource_id:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.microsoft.azure.advisor.recommendations.suppressions.utils.extract_resource_id:
            - json_response: '${json}'
        publish:
          - dismissed_resource_id
          - postponed_resource_id
        navigate:
          - SUCCESS: extract_dismissed_recommendation_id
  outputs:
    - return_result
    - status_code
    - error_message
    - postponed_resource_id
    - dismissed_resource_id
    - postponed_recommendation_id
    - dismissed_recommendation_id
    - json
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      api_call_to_list_recommendations:
        x: 40
        'y': 240
      set_success_message:
        x: 760
        'y': 240
        navigate:
          8ae983b7-334d-8dff-bc05-dd9a68302f6b:
            targetId: 336280f1-4a0b-157f-ffeb-4d461839dcc0
            port: SUCCESS
      extract_resource_id:
        x: 200
        'y': 240
      extract_dismissed_recommendation_id:
        x: 400
        'y': 240
      extract_postponed_recommendation_id:
        x: 600
        'y': 240
    results:
      SUCCESS:
        336280f1-4a0b-157f-ffeb-4d461839dcc0:
          x: 960
          'y': 240

