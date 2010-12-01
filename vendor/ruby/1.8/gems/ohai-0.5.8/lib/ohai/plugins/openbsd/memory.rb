#
# Author:: Mathieu Sauve-Frankel <msf@kisoku.net>
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

provides "memory"

memory Mash.new
memory[:swap] = Mash.new

# $ vmstat -s
#        4096 bytes per page
#      514011 pages managed
#      224519 pages free
#      209339 pages active
#        4647 pages inactive
#           0 pages being paged out
#           5 pages wired
#           0 pages zeroed
#           4 pages reserved for pagedaemon
#           6 pages reserved for kernel
#      262205 swap pages
#           0 swap pages in use
#           0 total anon's in system
#           0 free anon's
#  1192991609 page faults
#  1369579301 traps
#   814549706 interrupts
#   771702498 cpu context switches
#   208810590 fpu context switches
#   492361360 software interrupts
#  1161998825 syscalls
#           0 pagein operations
#           0 swap ins
#           0 swap outs
#      768352 forks
#          16 forks where vmspace is shared
#        1763 kernel map entries
#           0 number of times the pagedaemon woke up
#           0 revolutions of the clock hand
#           0 pages freed by pagedaemon
#           0 pages scanned by pagedaemon
#           0 pages reactivated by pagedaemon
#           0 busy pages found by pagedaemon
#  1096393776 total name lookups
#             cache hits (37% pos + 2% neg) system 1% per-directory
#             deletions 0%, falsehits 6%, toolong 26%
#           0 select collisions

popen4("vmstat -s") do |pid, stdin, stdout, stderr|
  stdin.close
  stdout.each do |line|
    case line
      when /(\d+) bytes per page/
        memory[:page_size] = $1
      when /(\d+) pages managed/
        memory[:page_count] = $1
        memory[:total] = memory[:page_size].to_i * memory[:page_count].to_i
      when /(\d+) pages free/
        memory[:free] = memory[:page_size].to_i * $1.to_i 
      when /(\d+) pages active/
        memory[:active] = memory[:page_size].to_i * $1.to_i 
      when /(\d+) pages inactive/
        memory[:inactive] = memory[:page_size].to_i * $1.to_i 
      when /(\d+) pages wired/
        memory[:wired] = memory[:page_size].to_i * $1.to_i 
      end
  end
end

popen4("swapctl -l") do |pid, stdin, stdout, stderr|
  stdin.close
  stdout.each do |line|
    # Device      1024-blocks     Used    Avail Capacity  Priority
    # swap_device     1048824        0  1048824     0%    0
    if line =~ /^([\d\w\/]+)\s+(\d+)\s+(\d+)\s+(\d+)\s+([\d\%]+)/
      mdev = $1
      memory[:swap][mdev] = Mash.new
      memory[:swap][mdev][:total] = $2
      memory[:swap][mdev][:used] = $3
      memory[:swap][mdev][:free] = $4
      memory[:swap][mdev][:percent_free] = $5
    end
  end
end
