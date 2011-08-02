module Fog
  module Terremark
    module Shared
      module Real

        # Instatiate a vapp template
        #
        # ==== Parameters
        # * name<~String>: Name of the resulting vapp .. must start with letter, up to 15 chars alphanumeric.
        # * options<~Hash>:
        # * cpus<~Integer>: Number of cpus in [1, 2, 4, 8], defaults to 1
        # * memory<~Integer>: Amount of memory either 512 or a multiple of 1024, defaults to 512
        # * vapp_template<~String>: id of the vapp template to be instantiated
        # ==== Returns
        # * response<~Excon::Response>:
        # * body<~Hash>:
        # * 'Links;<~Array> (e.g. up to vdc)
        # * 'href'<~String> Link to the resulting vapp
        # * 'name'<~String> - name of item
        # * 'type'<~String> - type of item
        # * 'status'<~String> - 0(pending) --> 2(off) -->4(on)
        def instantiate_vapp_template(name, vapp_template, options = {})
          unless name.length < 15
            raise ArgumentError.new('Name must be fewer than 15 characters')
          end
          options['cpus'] ||= 1
          options['memory'] ||= 512
          options['network_id'] ||= default_network_id
          options['vdc_id'] ||= default_vdc_id

          data = <<-DATA
<?xml version="1.0" encoding="UTF-8"?>
<InstantiateVAppTemplateParams name="#{name}" xmlns="http://www.vmware.com/vcloud/v0.8" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.vmware.com/vcloud/v0.8 http://services.vcloudexpress.terremark.com/api/v0.8/ns/vcloud.xsd">
  <VAppTemplate href="#{@scheme}://#{@host}/#{@path}/vAppTemplate/#{vapp_template}" />
  <InstantiationParams xmlns:vmw="http://www.vmware.com/schema/ovf">
    <ProductSection xmlns:ovf="http://schemas.dmtf.org/ovf/envelope/1" xmlns:q1="http://www.vmware.com/vcloud/v0.8"/>
    <VirtualHardwareSection xmlns:q1="http://www.vmware.com/vcloud/v0.8">
      <Item xmlns="http://schemas.dmtf.org/ovf/envelope/1">
        <InstanceID xmlns="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData">1</InstanceID>
        <ResourceType xmlns="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData">3</ResourceType>
        <VirtualQuantity xmlns="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData">#{options['cpus']}</VirtualQuantity>
      </Item>
      <Item xmlns="http://schemas.dmtf.org/ovf/envelope/1">
        <InstanceID xmlns="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData">2</InstanceID>
        <ResourceType xmlns="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData">4</ResourceType>
        <VirtualQuantity xmlns="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData">#{options['memory']}</VirtualQuantity>
      </Item>
    </VirtualHardwareSection>
    <NetworkConfigSection>
      <NetworkConfig>
        <NetworkAssociation href="#{@scheme}://#{@host}/#{@path}/network/#{options['network_id']}"/>
      </NetworkConfig>
    </NetworkConfigSection>
  </InstantiationParams>
</InstantiateVAppTemplateParams>
DATA

          request(
            :body => data,
            :expects => 200,
            :headers => { 'Content-Type' => 'application/vnd.vmware.vcloud.instantiateVAppTemplateParams+xml' },
            :method => 'POST',
            :parser => Fog::Parsers::Terremark::Shared::InstantiateVappTemplate.new,
            :path => "vdc/#{options['vdc_id']}/action/instantiatevAppTemplate"
          )
        end

      end

      module Mock

        def instatiate_vapp_template(vapp_template_id)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
