#
# Author:: Daniel DeLeo <dan@kallistec.com>
# Copyright:: Copyright (c) 2009 Daniel DeLeo
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

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper.rb')

describe Ohai::System, "Solaris2.X kernel plugin" do
  # NOTE: Solaris will report the same module loaded multiple times
  # with the same ID, Loadaddr, etc. and only the info column different
  # ignoring it, and removing the data from this fixture.
  MODINFO=<<-TOOMUCH
   Id Loadaddr   Size Info Rev Module Name
    6  1180000   4623   1   1  specfs (filesystem for specfs)
    8  1185df0   38c4   1   1  TS (time sharing sched class)
    9  1188f50    8dc   -   1  TS_DPTBL (Time sharing dispatch table)
   10  1188fe0  3623e   2   1  ufs (filesystem for ufs)
   11  11bc7ae    1ef   -   1  fssnap_if (File System Snapshot Interface)
   12  11bc8f6   1b3a   1   1  rootnex (sun4u root nexus 1.95)
   13  11be023    210  57   1  options (options driver)
   15  11be6ff   181a  12   1  sad (STREAMS Administrative Driver ')
   16  11bfc79    64b   2   1  pseudo (nexus driver for 'pseudo')
   17  11c0152  23563  32   1  sd (SCSI Disk Driver 1.447)
   18  11e160d   8c49   -   1  scsi (SCSI Bus Utility Routines)
   23  12171db  1072b  50   1  glm (GLM SCSI HBA Driver 1.191.)
   24  1225816   edcb 111   1  pcipsy (PCI Bus nexus driver 1.214)
   26  123e0eb   15b7   -   1  dada ( ATA Bus Utility Routines)
   27  123f30a    722   -   1  todmostek (tod module for Mostek M48T59 1.)
   28  11e7342  1a902   5   1  procfs (filesystem for proc)
   29  12335a1    da0 134   1  power (power button driver v1.10)
   30  1234199   15cb 126   1  ebus (ebus nexus driver 1.44)
   32  123f9a4  12215   6   1  sockfs (filesystem for sockfs)
   34  12365ba    6ae  11   1  clone (Clone Pseudodriver 'clone')
   35  1251709  7b1a6   0   1  ip (IP Streams module)
   36  1236a10    34f   1   1  ip6 (IP Streams module)
   37  12c56af  282d1   2   1  tcp (TCP Streams module)
   38  1236ba4   107d   -   1  md5 (MD5 Message-Digest Algorithm)
   39  1237b6c    365   3   1  tcp6 (TCP Streams module)
   40  1201148   a22f   4   1  udp (UDP Streams module)
   41  1237d11    365   5   1  udp6 (UDP Streams module)
   42  12096ef   86eb   6   1  icmp (ICMP Streams module)
   43  1237eb6    351   7   1  icmp6 (ICMP Streams module)
   44  123804c   6d5b   8   1  arp (ARP Streams module)
   45  1210282   46ba   9   1  timod (transport interface str mod)
   47  12152d1    c53  16   1  conskbd (Console kbd Multiplexer driver )
   48  1215b88   1ec2  15   1  wc (Workstation multiplexer Driver )
   49  12e66d4   516c  37   1  su (su driver 1.80)
   51  12ed065   4026  10   1  kb (streams module for keyboard)
   52  12efe3b   18c0  11   1  ms (streams module for mouse)
   53  12f14f7    a87  17   1  consms (Mouse Driver for Sun 'consms' 5)
   54  12f1bf6   b9d6 166   1  gfxp (TSI tspci driver %I%)
   55  12fb934    d77  14   1  iwscn (Workstation Redirection driver )
   58  1321301   4a4e   1   1  elfexec (exec module for elf)
   62  1328758  10bca   -   1  usba (USBA: USB Architecture 1.36)
   64  1337002   4884   -   1  mpxio (Multipath Interface Library v1.)
   68  131ded0   36d9   3   1  fifofs (filesystem for fifo)
   69  131248e   6888   -   1  fctl (Sun FC Transport Library v1.14)
   71  1345ddc  18cff   -   1  usba10 (USBA10: USB 1.0 Architecture 1.)
   75  135b92b   f0e2  12   1  ldterm (terminal line discipline)
   76  1326309   246d  13   1  ttcompat (alt ioctl calls)
   77  133b574   8cbb  29   1  zs (Z8530 serial driver V4.128)
   78  1343d27   15d0  26   1  ptsl (tty pseudo driver slave 'ptsl' )
   79  12fc4f3   1e77  25   1  ptc (tty pseudo driver control 'ptc')
   81  13748db   1d2c  14   1  rts (Routing Socket Streams module)
   88  136a112   ac5a  20   1  se (Siemens SAB 82532 ESCC2 1.128)
   89  13cf520   4be3 105   1  tl (TPI Local Transport Driver - tl)
   90  13d3d1b   48d3  17   1  keysock (PF_KEY Socket Streams module)
   91  13d7766   323f 234   1  spdsock (PF_POLICY Socket Streams device)
   92  137c3fb   1672  97   1  sysmsg (System message redirection (fan)
   93  12fe1ba    82c   0   1  cn (Console redirection driver 5.57)
   94 7814fba6    4b5   2   1  intpexec (exec mod for interp)
   95  12fe826    2cb  42   1  pipe (pipe(2) syscall)
   96  137d2dd   112d  13   1  mm (memory driver 1.68)
   97  13da515   ea79   7   1  hme (10/100Mb Ethernet Driver v1.167)
   98 78058000  2e313  85   1  md (Solaris Volume Manager base mod)
   99  13e6c82  127bc 226   1  rpcmod (RPC syscall)
  100  13f6ab6   1f99   -   1  tlimod (KTLI misc module)
  101  13f89a9   54e8   -   1  md_stripe (Solaris Volume Manager stripes )
  102 78086000  13316   -   1  md_mirror (Solaris Volume Manager mirrors )
  103 78084c17   1669  15   1  mntfs (mount information file system)
  105 78098156    fe0  12   1  fdfs (filesystem for fd)
  106 7809a000   46d7 201   1  doorfs (doors)
  107 7809e3c4   16e2   4   1  namefs (filesystem for namefs)
  108 780a0000  15ef2  11   1  tmpfs (filesystem for tmpfs)
  109 78098ca6   1054  90   1  kstat (kernel statistics driver 1.18)
  110  1375e9f   3aa9  88   1  devinfo (DEVINFO Driver 1.48)
  111  13fda05   25b9  38   1  openeepr (OPENPROM/NVRAM Driver v1.14)
  112 780a5886    9c7  21   1  log (streams log driver)
  113 780bc000  2c080 106   1  nfs (NFS syscall, client, and common)
  114 780ea000   4e43   -   1  rpcsec (kernel RPC security module.)
  115 780f4000   8667   -   1  klmmod (lock mgr common module)
  116 780f0000   354c   2   1  FX (Fixed priority sched class)
  117  137e232    2ae   -   1  FX_DPTBL (Fixed priority dispatch table)
  118 780fc000   668b  17   1  autofs (filesystem for autofs)
  119 780eeaab   1bba 104   1  random (random number device v1.8)
  120  12eb400   1b66   -   1  sha1 (SHA1 Message-Digest Algorithm)
  122 780f2788   13b8   -   1  bootdev (bootdev misc module 1.18)
  124 78124000   579e 127   1  pm (power management driver v1.104)
  125 781106aa   10b7 207   1  pset (processor sets)
  126 7812a000   289d  52   1  shmsys (System V shared memory)
  127  1216e2a    3dc   -   1  ipc (common ipc code)
  128 7812e000   ee14   -   1  md_raid (Solaris Volume Manager raid mod)
  129 7813e000   d0cd   -   1  md_trans (Solaris Volume Manager trans mo)
  130 7814c000   2a03   -   1  md_hotspares (Solaris Volume Manager hot spar)
  131 7814ab55   1004   -   1  md_notify (Solaris Volume Manager notifica)
  132 7809f7f6    903  22   1  sy (Indirect driver for tty 'sy' 1.)
  133 780e541c    d34  23   1  ptm (Master streams driver 'ptm' 1.4)
  134 7812c76d    d36  24   1  pts (Slave Stream Pseudo Terminal dr)
  135 7814e728   1617  19   1  ptem (pty hardware emulator)
  136 780e5eb8    2a5  20   1  redirmod (redirection module)
  137 78150000   6b71  91   1  vol (Volume Management Driver, 1.93)
  138  13285ad    2cf  21   1  connld (Streams-based pipes)
  139  137e27a    109   3   1  IA (interactive scheduling class)
  140 7813c544   1b10  22   1  hwc (streams module for hardware cur)
  141 78156871   170f  23   1  bufmod (streams buffer mod)
  142  1325c4c    838  72   1  ksyms (kernel symbols driver 1.25)
  143  12fea22  14864  33   1  st (SCSI tape Driver 1.238)
  144  1379790   2a12  53   1  semsys (System V semaphore facility)
  145  12138e4   15e4   4   1  RT (realtime scheduling class)
  146  121719e    28c   -   1  RT_DPTBL (realtime dispatch table)
  TOOMUCH
  
  before(:each) do
    @ohai = Ohai::System.new
    @ohai.stub!(:require_plugin).and_return(true)
    @ohai[:kernel] = Mash.new
    @ohai.stub(:from).with("uname -s").and_return("SunOS")
  end
  
  it_should_check_from_deep_mash("solaris2::kernel", "kernel", "os", "uname -s", "SunOS")

  it "gives excruciating detail about kernel modules" do
    stdin = mock("stdin", :null_object => true)
    @modinfo_stdout = StringIO.new(MODINFO)
    @ohai.stub!(:popen4).with("modinfo").and_yield(nil, stdin, @modinfo_stdout, nil)

    @ohai._require_plugin("solaris2::kernel")

    @ohai[:kernel][:modules].should have(107).modules

    # Teh daterz
    # Id Loadaddr   Size Info Rev Module Name
    #  6  1180000   4623   1   1  specfs (filesystem for specfs)
    teh_daterz = { "id" => 6, "loadaddr" => "1180000", "size" =>  17955, "description" => "filesystem for specfs"}
    @ohai[:kernel][:modules].keys.should include("specfs")
    @ohai[:kernel][:modules].keys.should_not include("Module")
    @ohai[:kernel][:modules]["specfs"].should == teh_daterz
  end
  
  
end