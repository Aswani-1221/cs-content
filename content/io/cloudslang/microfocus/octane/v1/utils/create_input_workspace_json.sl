########################################################################################################################
#!!
#!   (c) Copyright 2022 Micro Focus, L.P.
#!   All rights reserved. This program and the accompanying materials
#!   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#!
#!   The Apache License is available at
#!   http://www.apache.org/licenses/LICENSE-2.0
#!
#!   Unless required by applicable law or agreed to in writing, software
#!   distributed under the License is distributed on an "AS IS" BASIS,
#!   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#!   See the License for the specific language governing permissions and
#!   limitations under the License.
#!!#
########################################################################################################################
namespace: io.cloudslang.microfocus.octane.v1.utils
operation:
  name: create_input_workspace_json
  inputs:
    - name
  python_action:
    use_jython: false
    script: "# do not remove the execute function\ndef execute(name):\n    json = '''{\"data\":[\n        {\n              \"name\":\"''' + name + '''\"\n        }]\n    }'''\n \n    return locals()\n    # code goes here\n# you can add additional helper methods below."
  outputs:
    - json
  results:
    - SUCCESS
