#
# Author:: Bryan McLellan (btm@loftninjas.org)
# Copyright:: Copyright (c) 2009 Bryan McLellan
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

provides "virtualization"

virtualization Mash.new

# KVM Host support for FreeBSD is in development
# http://feanor.sssup.it/~fabio/freebsd/lkvm/

# Detect KVM/QEMU from cpu, report as KVM
# hw.model: QEMU Virtual CPU version 0.9.1
if from("sysctl -n hw.model") =~ /QEMU Virtual CPU/
  virtualization[:system] = "kvm"
  virtualization[:role] = "guest"
end

# http://www.dmo.ca/blog/detecting-virtualization-on-linux
if File.exists?("/usr/local/sbin/dmidecode")
  popen4("dmidecode") do |pid, stdin, stdout, stderr|
    stdin.close
    found_virt_manufacturer = nil
    found_virt_product = nil
    stdout.each do |line|
      case line
      when /Manufacturer: Microsoft/
        found_virt_manufacturer = "microsoft"
      when /Product Name: Virtual Machine/
        found_virt_product = "microsoft"
      when /Version: 5.0/
        if found_virt_manufacturer == "microsoft" && found_virt_product == "microsoft"
          virtualization[:system] = "virtualpc"
          virtualization[:role] = "guest"
        end
      when /Version: VS2005R2/
        if found_virt_manufacturer == "microsoft" && found_virt_product == "microsoft"
          virtualization[:system] = "virtualserver"
          virtualization[:role] = "guest"
        end
      when /Manufacturer: VMware/
        found_virt_manufacturer = "vmware"
      when /Product Name: VMware Virtual Platform/
        if found_virt_manufacturer == "vmware" 
          virtualization[:system] = "vmware"
          virtualization[:role] = "guest"
        end
      end
    end
  end
end

