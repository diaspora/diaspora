#
# Author:: Bryan McLellan (<btm@loftninjas.org>)
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


require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper.rb')

describe Ohai::System, "plugin dmi" do
  before(:each) do
    @ohai = Ohai::System.new
    @ohai.stub!(:from).with("dmidecode --version").and_return("2.9")
    @ohai.stub!(:from).with("dmidecode -s bios-vendor").and_return("Dell Inc.")
    @ohai.stub!(:from).with("dmidecode -s bios-version").and_return("2.6.1")
    @ohai.stub!(:from).with("dmidecode -s bios-release-date").and_return("12\/06\/2007")
    @ohai.stub!(:from).with("dmidecode -s system-manufacturer").and_return("Dell Inc.")
    @ohai.stub!(:from).with("dmidecode -s system-product-name").and_return("OptiPlex 745")
    @ohai.stub!(:from).with("dmidecode -s system-version").and_return("Not Specified")
    @ohai.stub!(:from).with("dmidecode -s system-serial-number").and_return("XXXXXXX")
    @ohai.stub!(:from).with("dmidecode -s system-uuid").and_return("44454C4C-4700-1032-8035-B9C04F474331")
    @ohai.stub!(:from).with("dmidecode -s baseboard-manufacturer").and_return("Dell Inc.")
    @ohai.stub!(:from).with("dmidecode -s baseboard-product-name").and_return("0RF703")
    @ohai.stub!(:from).with("dmidecode -s baseboard-version").and_return("Not Specified")
    @ohai.stub!(:from).with("dmidecode -s baseboard-serial-number").and_return("..CN137406CP0289.")
    @ohai.stub!(:from).with("dmidecode -s baseboard-asset-tag").and_return("None")
    @ohai.stub!(:from).with("dmidecode -s chassis-manufacturer").and_return("Dell Inc.")
    @ohai.stub!(:from).with("dmidecode -s chassis-type").and_return("Mini Tower")
    @ohai.stub!(:from).with("dmidecode -s chassis-version").and_return("Not Specified")
    @ohai.stub!(:from).with("dmidecode -s chassis-serial-number").and_return("XXXXXXX")
    @ohai.stub!(:from).with("dmidecode -s chassis-asset-tag").and_return("None")
    @ohai.stub!(:from).with("dmidecode -s processor-family").and_return("Not Specified")
    @ohai.stub!(:from).with("dmidecode -s processor-manufacturer").and_return("Intel")
    @ohai.stub!(:from).with("dmidecode -s processor-version").and_return("Not Specified")
    @ohai.stub!(:from).with("dmidecode -s processor-frequency").and_return("2000 Mhz")
  end

  it_should_check_from_deep_mash("dmi", "dmi", "version", "dmidecode --version", "2.9")
  it_should_check_from_deep_mash("dmi", [ "dmi", "bios" ], "vendor", "dmidecode -s bios-vendor", "Dell Inc.")
  it_should_check_from_deep_mash("dmi", [ "dmi", "bios" ], "version", "dmidecode -s bios-version", "2.6.1")
  it_should_check_from_deep_mash("dmi", [ "dmi", "bios" ], "release_date", "dmidecode -s bios-release-date", "12\/06\/2007")
  it_should_check_from_deep_mash("dmi", [ "dmi", "system" ], "manufacturer", "dmidecode -s system-manufacturer", "Dell Inc.")
  it_should_check_from_deep_mash("dmi", [ "dmi", "system" ], "product_name", "dmidecode -s system-product-name", "OptiPlex 745")
  it_should_check_from_deep_mash("dmi", [ "dmi", "system" ], "version", "dmidecode -s system-version", "Not Specified")
  it_should_check_from_deep_mash("dmi", [ "dmi", "system" ], "serial_number", "dmidecode -s system-serial-number", "XXXXXXX")
  it_should_check_from_deep_mash("dmi", [ "dmi", "system" ], "uuid", "dmidecode -s system-uuid", "44454C4C-4700-1032-8035-B9C04F474331")
  it_should_check_from_deep_mash("dmi", [ "dmi", "baseboard" ], "manufacturer", "dmidecode -s baseboard-manufacturer", "Dell Inc.")
  it_should_check_from_deep_mash("dmi", [ "dmi", "baseboard" ], "product_name", "dmidecode -s baseboard-product-name", "0RF703")
  it_should_check_from_deep_mash("dmi", [ "dmi", "baseboard" ], "version", "dmidecode -s baseboard-version", "Not Specified")
  it_should_check_from_deep_mash("dmi", [ "dmi", "baseboard" ], "serial_number", "dmidecode -s baseboard-serial-number", "..CN137406CP0289.")
  it_should_check_from_deep_mash("dmi", [ "dmi", "baseboard" ], "asset_tag", "dmidecode -s baseboard-asset-tag", "None")
  it_should_check_from_deep_mash("dmi", [ "dmi", "chassis" ], "manufacturer", "dmidecode -s chassis-manufacturer", "Dell Inc.")
  it_should_check_from_deep_mash("dmi", [ "dmi", "chassis" ], "type", "dmidecode -s chassis-type", "Mini Tower")
  it_should_check_from_deep_mash("dmi", [ "dmi", "chassis" ], "version", "dmidecode -s chassis-version", "Not Specified")
  it_should_check_from_deep_mash("dmi", [ "dmi", "chassis" ], "serial_number", "dmidecode -s chassis-serial-number", "XXXXXXX")
  it_should_check_from_deep_mash("dmi", [ "dmi", "chassis" ], "asset_tag", "dmidecode -s chassis-asset-tag", "None")
  it_should_check_from_deep_mash("dmi", [ "dmi", "processor" ], "family", "dmidecode -s processor-family", "Not Specified")
  it_should_check_from_deep_mash("dmi", [ "dmi", "processor" ], "manufacturer", "dmidecode -s processor-manufacturer", "Intel")
  it_should_check_from_deep_mash("dmi", [ "dmi", "processor" ], "version", "dmidecode -s processor-version", "Not Specified")
  it_should_check_from_deep_mash("dmi", [ "dmi", "processor" ], "frequency", "dmidecode -s processor-frequency", "2000 Mhz")
end
