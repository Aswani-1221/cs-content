#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
# Deletes an OpenStack server.
#
# Inputs:
#   - host - OpenStack machine host
#   - compute_port - optional - port used for OpenStack computations - Default: '8774'
#   - token - OpenStack token obtained after authentication
#   - tenant_id - OpenStack tenantID obtained after authentication
#   - server_id - ID of server to be deleted
#   - proxy_host - optional - proxy server used to access the web site - Default: none
#   - proxy_port - optional - proxy server port - Default: none
# Outputs:
#   - return_result - response of the operation
#   - status_code - normal status code is '204'
#   - error_message: returnResult if statusCode != '204'
# Results:
#   - SUCCESS - operation succeeded (statusCode == '204')
#   - FAILURE - otherwise
####################################################

namespace: io.cloudslang.openstack

operation:
  name: delete_openstack_server
  inputs:
    - host
    - compute_port: '8774'
    - token
    - tenant_id
    - server_id
    - proxy_host:
        required: false
    - proxy_port:
        required: false
    - proxyHost:
        default: ${proxy_host if proxy_host else ''}
        overridable: false
    - proxyPort:
        default: ${proxy_port if proxy_port else ''}
        overridable: false
    - headers:
        default: ${'X-AUTH-TOKEN:' + token}
        overridable: false
    - url:
        default: ${'http://'+ host + ':' + compute_port + '/v2/' + tenant_id + '/servers/' + server_id}
        overridable: false
    - method:
        default: 'delete'
        overridable: false
  action:
    java_action:
      className: io.cloudslang.content.httpclient.HttpClientAction
      methodName: execute
  outputs:
    - return_result: ${'' if 'returnResult' not in locals() else returnResult}
    - status_code: ${statusCode}
    - error_message: ${returnResult if statusCode != '204' else ''}
  results:
    - SUCCESS: ${'statusCode' in locals() and statusCode == '204'}
    - FAILURE