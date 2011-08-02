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

provides "dmi"

# dmidecode does not return data without access to /dev/mem (or its equivalent)

dmi Mash.new
dmi[:version] = from("dmidecode --version")

dmi[:bios] = Mash.new
dmi[:bios][:vendor] =             from("dmidecode -s bios-vendor")
dmi[:bios][:version] =            from("dmidecode -s bios-version")
dmi[:bios][:release_date] =       from("dmidecode -s bios-release-date")

dmi[:system] = Mash.new
dmi[:system][:manufacturer] =     from("dmidecode -s system-manufacturer")
dmi[:system][:product_name] =     from("dmidecode -s system-product-name")
dmi[:system][:version] =          from("dmidecode -s system-version")
dmi[:system][:serial_number] =    from("dmidecode -s system-serial-number")

dmi[:baseboard] = Mash.new
dmi[:baseboard][:manufacturer] =  from("dmidecode -s baseboard-manufacturer")
dmi[:baseboard][:product_name] =  from("dmidecode -s baseboard-product-name")
dmi[:baseboard][:version] =       from("dmidecode -s baseboard-version")
dmi[:baseboard][:serial_number] = from("dmidecode -s baseboard-serial-number")
dmi[:baseboard][:asset_tag] =     from("dmidecode -s baseboard-asset-tag")

dmi[:chassis] = Mash.new
dmi[:chassis][:manufacturer] =    from("dmidecode -s chassis-manufacturer")
dmi[:chassis][:version] =         from("dmidecode -s chassis-version")
dmi[:chassis][:serial_number] =   from("dmidecode -s chassis-serial-number")
dmi[:chassis][:asset_tag] =       from("dmidecode -s chassis-asset-tag")

dmi[:processor] = Mash.new
dmi[:processor][:manufacturer] =  from("dmidecode -s processor-manufacturer")
dmi[:processor][:version] =       from("dmidecode -s processor-version")

if dmi[:version].to_f >= 2.8
  dmi[:chassis][:type] =            from("dmidecode -s chassis-type")
  dmi[:system][:uuid] =             from("dmidecode -s system-uuid") 
  dmi[:processor][:family] =        from("dmidecode -s processor-family") 
  dmi[:processor][:frequency] =     from("dmidecode -s processor-frequency")
end
