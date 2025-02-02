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
#! @description: This workflow is used to start the vApp.
#!
#! @input provider_sap: Provider SAP.
#! @input vapp_id: The unique id of the vApp.
#! @input api_token: The Refresh token for the Vcloud.
#! @input tenant_name: The organization we are attempting to access.
#! @input worker_group: A worker group is a logical collection of workers. A worker may belong to more than one group
#!                      simultaneously.
#!                      Default: 'RAS_Operator_Path'
#!                      Optional
#! @input polling_interval: The number of seconds to wait until performing another check.Default: '20'Optional
#! @input polling_retries: The number of retries to check if the instance is started.Default: '30'Optional
#! @input proxy_host: Proxy server used to access the web site.
#!                    Optional
#! @input proxy_port: Proxy server port.
#!                    Optional
#! @input proxy_username: Username used when connecting to the proxy.
#!                        Optional
#! @input proxy_password: Proxy server password associated with the <proxy_username> input value.
#!                        Optional
#! @input trust_all_roots: Specifies whether to enable weak security over SSL.
#!                         Default: 'false'
#!                         Optional
#! @input x_509_hostname_verifier: specifies the way the server hostname must match a domain name in
#!                                 the subject's Common Name (CN) or subjectAltName field of the X.509 certificate
#!                                 Valid: 'strict', 'browser_compatible', 'allow_all' - Default: 'allow_all'
#!                                 Default: 'strict'
#!                                 Optional
#! @input trust_keystore: The pathname of the Java TrustStore file. This contains certificates from
#!                        other parties that you expect to communicate with, or from Certificate Authorities that
#!                        you trust to identify other parties.  If the protocol (specified by the 'url') is not
#!                        'https' or if trust_all_roots is 'true' this input is ignored.
#!                        Default value: ..JAVA_HOME/java/lib/security/cacerts
#!                        Format: Java KeyStore (JKS)
#!                        Optional
#! @input trust_password: The password associated with the trust_keystore file. If trust_all_roots is false
#!                        and trust_keystore is empty, trust_password default will be supplied.
#!                        Optional
#!
#! @output vm_mac_address_list: The list of MAC address of VMs.
#! @output vm_id_list: The list of ID of VMs.
#! @output vm_ip_list: The list of IP address of VMs.
#! @output vm_name_list: The list of VM name.
#! @output vapp_status: The status of created vApp.
#!
#! @result SUCCESS: The vApp has been  started successfully.
#! @result FAILURE: Error in starting vApp.
#!!#
########################################################################################################################

namespace: io.cloudslang.vmware.cloud_director
imports:
  http: io.cloudslang.base.http
  json: io.cloudslang.base.json
flow:
  name: vcloud_start_vapp
  inputs:
    - provider_sap
    - vapp_id:
        required: true
        sensitive: false
    - api_token:
        sensitive: true
    - tenant_name
    - worker_group:
        default: RAS_Operator_Path
        required: false
    - polling_interval: '20'
    - polling_retries: '30'
    - proxy_host:
        required: false
    - proxy_port:
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
  workflow:
    - get_host_details:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.vmware.cloud_director.utils.get_host_details:
            - provider_sap: '${provider_sap}'
        publish:
          - hostname
          - protocol
          - port
        navigate:
          - SUCCESS: get_access_token_using_web_api
    - get_access_token_using_web_api:
        worker_group:
          value: '${worker_group}'
          override: true
        do:
          io.cloudslang.vmware.cloud_director.authorization.get_access_token_using_web_api:
            - host_name: '${hostname}'
            - protocol: '${protocol}'
            - port: '${port}'
            - organization: '${tenant_name}'
            - refresh_token:
                value: '${api_token}'
                sensitive: true
            - worker_group: '${worker_group}'
            - proxy_host: '${proxy_host}'
            - proxy_port: '${proxy_port}'
            - proxy_username: '${proxy_username}'
            - proxy_password:
                value: '${proxy_password}'
                sensitive: true
            - trust_all_roots: '${trust_all_roots}'
            - x_509_hostname_verifier: '${x_509_hostname_verifier}'
            - trust_keystore: '${trust_keystore}'
            - trust_password:
                value: '${trust_password}'
                sensitive: true
        publish:
          - access_token
        navigate:
          - SUCCESS: get_vapp_details
          - FAILURE: on_failure
    - get_vapp_details:
        worker_group:
          value: '${worker_group}'
          override: true
        do:
          io.cloudslang.vmware.cloud_director.vapp.get_vapp_details:
            - host_name: '${hostname}'
            - port: '${port}'
            - protocol: '${protocol}'
            - access_token: '${access_token}'
            - vapp_id: '${vapp_id}'
            - proxy_host: '${proxy_host}'
            - proxy_port: '${proxy_port}'
            - proxy_username: '${proxy_username}'
            - worker_group: '${worker_group}'
            - proxy_password:
                value: '${proxy_password}'
                sensitive: true
            - trust_all_roots: '${trust_all_roots}'
            - x_509_hostname_verifier: '${x_509_hostname_verifier}'
            - trust_keystore: '${trust_keystore}'
            - trust_password:
                value: '${trust_password}'
                sensitive: true
        publish:
          - vapp_details: '${return_result}'
          - status
        navigate:
          - SUCCESS: string_equals
          - FAILURE: on_failure
    - string_equals:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${status}'
            - second_string: '4'
        navigate:
          - SUCCESS: get_vm_id_list
          - FAILURE: start_vapp
    - check_power_state:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.base.json.get_value:
            - json_input: '${vapp_details}'
            - json_path: status
        publish:
          - power_state: '${return_result}'
        navigate:
          - SUCCESS: compare_power_state
          - FAILURE: on_failure
    - compare_power_state:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${power_state}'
            - second_string: '4'
        navigate:
          - SUCCESS: get_vm_id_list
          - FAILURE: counter
    - sleep:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.base.utils.sleep:
            - seconds: '30'
        navigate:
          - SUCCESS: get_vapp_details_1
          - FAILURE: on_failure
    - get_vapp_details_1:
        worker_group:
          value: '${worker_group}'
          override: true
        do:
          io.cloudslang.vmware.cloud_director.vapp.get_vapp_details:
            - host_name: '${hostname}'
            - port: '${port}'
            - protocol: '${protocol}'
            - access_token: '${access_token}'
            - vapp_id: '${vapp_id}'
            - proxy_host: '${proxy_host}'
            - proxy_port: '${proxy_port}'
            - proxy_username: '${proxy_username}'
            - worker_group: '${worker_group}'
            - proxy_password:
                value: '${proxy_password}'
                sensitive: true
            - trust_all_roots: '${trust_all_roots}'
            - x_509_hostname_verifier: '${x_509_hostname_verifier}'
            - trust_keystore: '${trust_keystore}'
            - trust_password:
                value: '${trust_password}'
                sensitive: true
        publish:
          - vapp_details: '${return_result}'
          - status
        navigate:
          - SUCCESS: check_power_state
          - FAILURE: on_failure
    - start_vapp:
        worker_group:
          value: '${worker_group}'
          override: true
        do:
          io.cloudslang.vmware.cloud_director.vapp.start_vapp:
            - host_name: '${hostname}'
            - port: '${port}'
            - protocol: '${protocol}'
            - vApp_id: '${vapp_id}'
            - access_token: '${access_token}'
            - proxy_host: '${proxy_host}'
            - proxy_username: '${proxy_username}'
            - proxy_port: '${proxy_port}'
            - proxy_password:
                value: '${proxy_password}'
                sensitive: true
            - worker_group: '${worker_group}'
            - trust_all_roots: '${trust_all_roots}'
            - x_509_hostname_verifier: '${x_509_hostname_verifier}'
            - trust_keystore: '${trust_keystore}'
            - trust_password:
                value: '${trust_password}'
                sensitive: true
        navigate:
          - SUCCESS: get_vapp_details_1
          - FAILURE: on_failure
    - counter:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.base.utils.counter:
            - from: '1'
            - to: '${polling_retries}'
            - increment_by: '1'
            - reset: 'false'
        navigate:
          - HAS_MORE: sleep
          - NO_MORE: FAILURE
          - FAILURE: on_failure
    - is_vm_ip_list_is_null:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${vm_ip}'
            - second_string: 'null'
        publish: []
        navigate:
          - SUCCESS: set_vm_ip_list_to_empty
          - FAILURE: get_vm_mac_address
    - set_first_vm_ip_and_mac_address:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.base.utils.do_nothing:
            - vm_ip: '${vm_ip}'
            - vm_mac_address: '${vm_mac_address}'
        publish:
          - vm_ip_list: '${vm_ip}'
          - vm_mac_address_list: '${vm_mac_address}'
        navigate:
          - SUCCESS: list_iterator
          - FAILURE: on_failure
    - get_vm_id_list:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${vapp_details}'
            - json_path: '$.children.vm[*].id'
            - vm_ip_list: ''
            - vm_mac_address_list: ''
        publish:
          - vm_id_list: "${return_result.replace('urn:vcloud:vm:','vm-').replace('\"','').strip('[').strip(']').replace(' ','')}"
          - vm_ip_list
          - vm_mac_address_list
        navigate:
          - SUCCESS: get_vm_names
          - FAILURE: on_failure
    - get_vm_mac_address:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${vapp_details}'
            - json_path: "${'$.children.vm[?(@.name==\"'+vm+'\")].section[?(@._type==\"NetworkConnectionSectionType\")].networkConnection[0].macAddress'}"
        publish:
          - vm_mac_address: "${return_result.strip('[\"').strip('\"]')}"
        navigate:
          - SUCCESS: is_vm_ip_list_is_empty
          - FAILURE: on_failure
    - get_vm_ip:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${vapp_details}'
            - json_path: "${'$.children.vm[?(@.name==\"'+vm+'\")].section[?(@._type==\"NetworkConnectionSectionType\")].networkConnection[0].ipAddress'}"
        publish:
          - vm_ip: "${return_result.strip('[\"').strip('\"]')}"
        navigate:
          - SUCCESS: is_vm_ip_list_is_null
          - FAILURE: on_failure
    - set_vm_ip_and_mac_address:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.base.utils.do_nothing:
            - vm_ip: '${vm_ip}'
            - vm_ip_list: '${vm_ip_list}'
            - vm_mac_address: '${vm_mac_address}'
            - vm_mac_address_list: '${vm_mac_address_list}'
        publish:
          - vm_ip_list: "${vm_ip_list+','+vm_ip}"
          - vm_mac_address_list: "${vm_mac_address_list+','+vm_mac_address}"
        navigate:
          - SUCCESS: list_iterator
          - FAILURE: on_failure
    - list_iterator:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${vm_name_list}'
            - vm_ip_list: '${vm_ip_list}'
            - vm_mac_address_list: '${vm_mac_address_list}'
        publish:
          - vm: '${result_string}'
          - vm_ip_list
          - vm_mac_address_list
        navigate:
          - HAS_MORE: get_vm_ip
          - NO_MORE: is_vm_status_is_8
          - FAILURE: on_failure
    - is_vm_ip_list_is_empty:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${vm_ip_list}'
            - second_string: ''
        publish: []
        navigate:
          - SUCCESS: set_first_vm_ip_and_mac_address
          - FAILURE: set_vm_ip_and_mac_address
    - set_vm_ip_list_to_empty:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.base.utils.do_nothing:
            - vm_ip: ''
        publish:
          - vm_ip
        navigate:
          - SUCCESS: get_vm_mac_address
          - FAILURE: on_failure
    - get_vm_names:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${vapp_details}'
            - json_path: '$.children.vm[*].name'
            - vapp_status: '${status}'
        publish:
          - vm_name_list: "${return_result.replace('\"','').strip('[').strip(']')}"
          - vapp_status
        navigate:
          - SUCCESS: list_iterator
          - FAILURE: on_failure
    - set_vm_status_to_powered_off:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.base.utils.do_nothing:
            - vapp_status: Powered Off
        publish:
          - vapp_status
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - is_vm_status_is_4:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${vapp_status}'
            - second_string: '4'
        publish: []
        navigate:
          - SUCCESS: set_vm_status_to_powered_on
          - FAILURE: on_failure
    - set_vm_status_to_powered_on:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.base.utils.do_nothing:
            - vapp_status: Powered On
        publish:
          - vapp_status
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
    - is_vm_status_is_8:
        worker_group: '${worker_group}'
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${vapp_status}'
            - second_string: '8'
        publish: []
        navigate:
          - SUCCESS: set_vm_status_to_powered_off
          - FAILURE: is_vm_status_is_4
  outputs:
    - vm_mac_address_list
    - vm_id_list
    - vm_ip_list
    - vm_name_list
    - vapp_status
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      check_power_state:
        x: 440
        'y': 200
      is_vm_ip_list_is_null:
        x: 1000
        'y': 240
      set_first_vm_ip_and_mac_address:
        x: 1000
        'y': 800
      get_vm_id_list:
        x: 440
        'y': 320
      get_vm_mac_address:
        x: 1200
        'y': 600
      get_vm_ip:
        x: 1000
        'y': 440
      start_vapp:
        x: 240
        'y': 280
      get_vapp_details_1:
        x: 240
        'y': 120
      get_vm_names:
        x: 240
        'y': 720
      string_equals:
        x: 240
        'y': 520
      set_vm_ip_and_mac_address:
        x: 1000
        'y': 600
      list_iterator:
        x: 440
        'y': 520
      set_vm_status_to_powered_off:
        x: 440
        'y': 720
        navigate:
          69c19c2c-4abc-af31-2d1e-411657f6f342:
            targetId: 11a314fb-962f-5299-d0a5-ada1540d2904
            port: SUCCESS
      get_host_details:
        x: 40
        'y': 120
      is_vm_ip_list_is_empty:
        x: 1200
        'y': 800
      get_vapp_details:
        x: 40
        'y': 520
      sleep:
        x: 560
        'y': 40
      is_vm_status_is_4:
        x: 640
        'y': 960
      get_access_token_using_web_api:
        x: 40
        'y': 280
      set_vm_status_to_powered_on:
        x: 440
        'y': 960
        navigate:
          88ba7dc0-4368-8a15-7aca-d5fc17b979cd:
            targetId: 11a314fb-962f-5299-d0a5-ada1540d2904
            port: SUCCESS
      counter:
        x: 800
        'y': 120
        navigate:
          64a54e74-0859-6965-a06f-c00bfc259048:
            targetId: d6c9a535-7035-57ef-2851-365363e4fbd6
            port: NO_MORE
      compare_power_state:
        x: 640
        'y': 280
      is_vm_status_is_8:
        x: 640
        'y': 720
      set_vm_ip_list_to_empty:
        x: 1200
        'y': 240
    results:
      SUCCESS:
        11a314fb-962f-5299-d0a5-ada1540d2904:
          x: 160
          'y': 960
      FAILURE:
        d6c9a535-7035-57ef-2851-365363e4fbd6:
          x: 1000
          'y': 120

