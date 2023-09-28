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
#! @description: Deletes a Consul key if the key exists.
#!
#! @input host: Consul Agent host.
#! @input consul_port: Optional - Consul agent port.
#!                     Default: '8500'
#! @input key_name: Name of key to delete.
#!
#! @output return_result: Response of the operation.
#! @output error_message: Return_result if return_code is equal to ': 1' or status_code different than '200'.
#! @output return_code: If return_code is equal to '-1' then there was an error.
#! @output status_code: Normal status code is '200'.
#!
#! @result SUCCESS: Operation succeeded (return_code != '-1' and status_code == '200').
#! @result FAILURE: Otherwise.
#!!#
########################################################################################################################

namespace: io.cloudslang.consul

operation:
  name: delete_kv

  inputs:
    - host
    - consul_port:
        default: "8500"
        required: false
    - key_name
    - url:
        default: ${'http://' + host + ':' + consul_port + '/v1/kv/' + key_name}
        private: true
    - method:
        default: "delete"
        private: true

  java_action:
    gav: 'io.cloudslang.content:cs-http-client:0.1.88'
    class_name: io.cloudslang.content.httpclient.HttpClientAction
    method_name: execute

  outputs:
    - return_result: ${returnResult}
    - error_message: ${returnResult if returnCode == '-1' or statusCode != '200' else ''}
    - return_code: ${returnCode}
    - status_code: ${statusCode}

  results:
    - SUCCESS: ${returnCode != '-1' and statusCode == '200'}
    - FAILURE
