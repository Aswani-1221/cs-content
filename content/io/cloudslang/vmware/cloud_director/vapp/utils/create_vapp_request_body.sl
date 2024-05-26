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
#! @description: The python operation to form the request body for create vApp flow.
#!
#! @input name: The name of vApp.
#! @input template_json: The JSON output of template.
#!
#! @output return_result: The request body for vApp create flow.
#!
#! @result SUCCESS: Formed the request body for create vApp.
#!!#
########################################################################################################################
namespace: io.cloudslang.vmware.cloud_director.utils
operation:
  name: create_vapp_request_body
  inputs:
    - name
    - template_json
  python_action:
    use_jython: false
    script: "# do not remove the execute function\r\nimport json\r\ndef execute(name,template_json):\r\n    return_result = '<root:InstantiateVAppTemplateParams xmlns:root=\"http://www.vmware.com/vcloud/v1.5\" name=\"'+name+'\" xmlns:ns0=\"http://schemas.dmtf.org/ovf/envelope/1\" xmlns:ns1=\"http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData\" xmlns:ns2=\"http://www.vmware.com/schema/ovf\"><root:Description/> <root:InstantiationParams><root:LeaseSettingsSection><ns0:Info/><root:DeploymentLeaseInSeconds>0</root:DeploymentLeaseInSeconds><root:StorageLeaseInSeconds>0</root:StorageLeaseInSeconds></root:LeaseSettingsSection>'\r\n    \r\n    \r\n    template_json = json.loads(template_json)\r\n    for x in template_json[\"section\"] :\r\n        if x[\"_type\"] == \"NetworkConfigSectionType\" :\r\n            return_result +='<root:NetworkConfigSection><ns0:Info/><root:NetworkConfig networkName=\"'+x[\"networkConfig\"][0][\"networkName\"]+'\"><root:Description/><root:Configuration><root:IpScopes><root:IpScope><root:IsInherited>'+str(x[\"networkConfig\"][0][\"configuration\"][\"ipScopes\"][\"ipScope\"][0][\"isInherited\"]).lower()+'</root:IsInherited><root:Gateway>'+str(x[\"networkConfig\"][0][\"configuration\"][\"ipScopes\"][\"ipScope\"][0][\"gateway\"])+'</root:Gateway><root:Netmask>'+str(x[\"networkConfig\"][0][\"configuration\"][\"ipScopes\"][\"ipScope\"][0][\"netmask\"])+'</root:Netmask><root:SubnetPrefixLength>'+str(x[\"networkConfig\"][0][\"configuration\"][\"ipScopes\"][\"ipScope\"][0][\"subnetPrefixLength\"])+'</root:SubnetPrefixLength>'\r\n            if (x[\"networkConfig\"][0][\"configuration\"][\"ipScopes\"][\"ipScope\"][0][\"dns1\"]) != (None) :\r\n                return_result += '<root:Dns1>'+str(x[\"networkConfig\"][0][\"configuration\"][\"ipScopes\"][\"ipScope\"][0][\"dns1\"])+'</root:Dns1><root:Dns2>'+str(x[\"networkConfig\"][0][\"configuration\"][\"ipScopes\"][\"ipScope\"][0][\"dns2\"])+'</root:Dns2><root:DnsSuffix>'+str(x[\"networkConfig\"][0][\"configuration\"][\"ipScopes\"][\"ipScope\"][0][\"dnsSuffix\"])+'</root:DnsSuffix>'\r\n            return_result += '<root:IsEnabled>'+str(x[\"networkConfig\"][0][\"configuration\"][\"ipScopes\"][\"ipScope\"][0][\"isEnabled\"]).lower()+'</root:IsEnabled><root:IpRanges><root:IpRange><root:StartAddress>'+str(x[\"networkConfig\"][0][\"configuration\"][\"ipScopes\"][\"ipScope\"][0][\"ipRanges\"][\"ipRange\"][0][\"startAddress\"])+'</root:StartAddress><root:EndAddress>'+str(x[\"networkConfig\"][0][\"configuration\"][\"ipScopes\"][\"ipScope\"][0][\"ipRanges\"][\"ipRange\"][0][\"endAddress\"])+'</root:EndAddress></root:IpRange></root:IpRanges></root:IpScope></root:IpScopes>'\r\n            if (x[\"networkConfig\"][0][\"configuration\"][\"parentNetwork\"]) != (None) :\r\n                return_result += '<root:ParentNetwork href=\"'+x[\"networkConfig\"][0][\"configuration\"][\"parentNetwork\"][\"href\"]+'\" id=\"'+x[\"networkConfig\"][0][\"configuration\"][\"parentNetwork\"][\"id\"]+'\" name=\"'+x[\"networkConfig\"][0][\"configuration\"][\"parentNetwork\"][\"name\"]+'\"/>'\r\n            return_result += '<root:FenceMode>'+x[\"networkConfig\"][0][\"configuration\"][\"fenceMode\"]+'</root:FenceMode><root:RetainNetInfoAcrossDeployments>'+str(x[\"networkConfig\"][0][\"configuration\"][\"retainNetInfoAcrossDeployments\"]).lower()+'</root:RetainNetInfoAcrossDeployments><root:GuestVlanAllowed>'+str(x[\"networkConfig\"][0][\"configuration\"][\"guestVlanAllowed\"]).lower()+'</root:GuestVlanAllowed></root:Configuration><root:IsDeployed>'+str(x[\"networkConfig\"][0][\"isDeployed\"]).lower()+'</root:IsDeployed></root:NetworkConfig></root:NetworkConfigSection></root:InstantiationParams>'\r\n            break\r\n    return_result +='<root:Source href=\"'+template_json[\"href\"]+'\" id=\"'+template_json[\"id\"]+'\" name=\"'+template_json[\"name\"]+'\"/><root:IsSourceDelete>false</root:IsSourceDelete>'\r\n    for x in template_json[\"children\"][\"vm\"]:\r\n        storage_profile = ''\r\n        return_result += '<root:SourcedItem><root:Source href=\"'+x[\"href\"]+'\"/><root:VmGeneralParams><root:Name>'+x[\"name\"]+'</root:Name></root:VmGeneralParams><root:InstantiationParams>'\r\n        for y in x[\"section\"]:\r\n            if y[\"_type\"] == \"VirtualHardwareSectionType\":\r\n                return_result += '<ns0:VirtualHardwareSection><ns0:Info>'+y[\"info\"][\"value\"]+'</ns0:Info>'\r\n                for z in y[\"item\"] :\r\n                    if z[\"description\"][\"value\"] == \"Hard disk\" :\r\n                        storage_profile = z[\"hostResource\"][0][\"otherAttributes\"][\"{http://www.vmware.com/vcloud/v1.5}storageProfileHref\"]\r\n                        return_result += '<ns0:Item><ns1:AddressOnParent>'+str(z[\"addressOnParent\"][\"value\"])+'</ns1:AddressOnParent><ns1:Description>'+z[\"description\"][\"value\"]+'</ns1:Description><ns1:ElementName>'+z[\"elementName\"][\"value\"]+'</ns1:ElementName><ns1:HostResource root:busType=\"'+z[\"hostResource\"][0][\"otherAttributes\"][\"{http://www.vmware.com/vcloud/v1.5}busType\"]+'\" root:busSubType=\"'+z[\"hostResource\"][0][\"otherAttributes\"][\"{http://www.vmware.com/vcloud/v1.5}busSubType\"]+'\" root:capacity=\"'+str(z[\"hostResource\"][0][\"otherAttributes\"][\"{http://www.vmware.com/vcloud/v1.5}capacity\"])+'\" root:iops=\"'+str(z[\"hostResource\"][0][\"otherAttributes\"][\"{http://www.vmware.com/vcloud/v1.5}iops\"])+'\" root:storageProfileOverrideVmDefault=\"'+str(z[\"hostResource\"][0][\"otherAttributes\"][\"{http://www.vmware.com/vcloud/v1.5}storageProfileOverrideVmDefault\"])+'\"/><ns1:InstanceID>'+str(z[\"instanceID\"][\"value\"])+'</ns1:InstanceID><ns1:ResourceType>'+str(z[\"resourceType\"][\"value\"])+'</ns1:ResourceType><ns1:VirtualQuantity>'+str(z[\"virtualQuantity\"][\"value\"])+'</ns1:VirtualQuantity><ns1:VirtualQuantityUnits>'+z[\"virtualQuantityUnits\"][\"value\"]+'</ns1:VirtualQuantityUnits></ns0:Item>'\r\n                    elif z[\"description\"][\"value\"] == \"Number of Virtual CPUs\" :\r\n                        return_result += '<ns0:Item><ns1:AllocationUnits>'+z[\"allocationUnits\"][\"value\"]+'</ns1:AllocationUnits><ns1:Description>'+z[\"description\"][\"value\"]+'</ns1:Description><ns1:ElementName>'+z[\"elementName\"][\"value\"]+'</ns1:ElementName><ns1:InstanceID>'+str(z[\"instanceID\"][\"value\"])+'</ns1:InstanceID>'\r\n                        if (z[\"limit\"]) != None :\r\n                            return_result += '<ns1:Limit>'+str(z[\"limit\"][\"value\"])+'</ns1:Limit>'\r\n                        return_result += '<ns1:Reservation>'+str(z[\"reservation\"][\"value\"])+'</ns1:Reservation><ns1:ResourceType>'+str(z[\"resourceType\"][\"value\"])+'</ns1:ResourceType><ns1:VirtualQuantity>'+str(z[\"virtualQuantity\"][\"value\"])+'</ns1:VirtualQuantity><ns1:Weight>'+str(z[\"weight\"][\"value\"])+'</ns1:Weight>'\r\n                        for cps in z[\"any\"]:\r\n                            if cps[\"_type\"] == \"CoresPerSocketType\" :\r\n                                return_result += '<ns2:CoresPerSocket>'+str(cps[\"value\"])+'</ns2:CoresPerSocket>'\r\n                        return_result = return_result + '</ns0:Item>'\r\n                    elif z[\"description\"][\"value\"] == \"Memory Size\" :\r\n                        return_result += '<ns0:Item><ns1:AllocationUnits>'+z[\"allocationUnits\"][\"value\"]+'</ns1:AllocationUnits><ns1:Description>'+z[\"description\"][\"value\"]+'</ns1:Description><ns1:ElementName>'+z[\"elementName\"][\"value\"]+'</ns1:ElementName><ns1:InstanceID>'+str(z[\"instanceID\"][\"value\"])+'</ns1:InstanceID>'\r\n                        if(z[\"limit\"]) != None :\r\n                            return_result += '<ns1:Limit>'+str(z[\"limit\"][\"value\"])+'</ns1:Limit>'\r\n                        return_result += '<ns1:Reservation>'+str(z[\"reservation\"][\"value\"])+'</ns1:Reservation><ns1:ResourceType>'+str(z[\"resourceType\"][\"value\"])+'</ns1:ResourceType><ns1:VirtualQuantity>'+str(z[\"virtualQuantity\"][\"value\"])+'</ns1:VirtualQuantity></ns0:Item>'\r\n                    \r\n        return_result += '</ns0:VirtualHardwareSection></root:InstantiationParams><root:StorageProfile href=\"https://vcloud.btp.swinfra.net/api/vdcStorageProfile/bf63a648-08fb-40b7-ac76-2b327e0921dd\"/></root:SourcedItem>'\r\n        for y in x[\"section\"]:\r\n            if y[\"_type\"] == \"VmSpectSectionType\":\r\n                return_result += '<ns0:VirtualHardwareSection><ns0:Info>'+y[\"info\"][\"value\"]+'\"</ns0:Info><root:StorageProfile href=\"'+storage_profile+'\"/><root:ComputePolicy/></root:SourcedItem>'\r\n            break\r\n    return_result += '\t<root:AllEULAsAccepted>true</root:AllEULAsAccepted></root:InstantiateVAppTemplateParams>'\r\n    return{\"return_result\":return_result}\r\n    # code goes here\r\n# you can add additional helper methods below."
  outputs:
    - return_result
  results:
    - SUCCESS

