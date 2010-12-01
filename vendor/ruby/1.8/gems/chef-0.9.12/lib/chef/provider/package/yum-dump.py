#
# Author:: Matthew Kent (<mkent@magoazul.com>)
# Copyright:: Copyright (c) 2009 Matthew Kent
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

# yum-dump.py
# Inspired by yumhelper.py by David Lutterkort
#
# Produce a list of installed and available packages using yum and dump the 
# result to stdout.
#
# This invokes yum just as the command line would which makes it subject to 
# all the caching related configuration paramaters in yum.conf.
#
# Can be run as non root, but that won't update the cache.

import os
import sys
import time
import yum

from yum import Errors

PIDFILE='/var/run/yum.pid'

# Seconds to wait for exclusive access to yum
lock_timeout = 10

failure = False 

# Can't do try: except: finally: in python 2.4 it seems, hence this fun.
try:
  try:
    y = yum.YumBase()
    try:
        # Only want our output
        y.doConfigSetup(errorlevel=0,debuglevel=0)
    except:
        # but of course, yum on even moderately old
        # redhat/centosen doesn't know how to do logging properly
        # so we duck punch our way to victory
        def __log(a,b): pass
        y.doConfigSetup()
        y.log = __log
        y.errorlog = __log
    
    # Yum assumes it can update the cache directory. Disable this for non root 
    # users.
    y.conf.cache = os.geteuid() != 0

    # Override any setting in yum.conf - we only care about the newest
    y.conf.showdupesfromrepos = False

    # Spin up to lock_timeout.
    countdown = lock_timeout
    while True:
      try:
        y.doLock(PIDFILE)
      except Errors.LockError, e:
        time.sleep(1)
        countdown -= 1 
        if countdown == 0:
           print >> sys.stderr, "Error! Couldn't obtain an exclusive yum lock in %d seconds. Giving up." % lock_timeout
           failure = True
           sys.exit(1)
      else:
        break
    
    y.doTsSetup()
    y.doRpmDBSetup()
    
    try:
        db = y.doPackageLists('all')
    except AttributeError:
        # some people claim that testing for yum.__version__ should be
        # enough to see if this is required, but I say they're liars.
        # the yum on 4.8 at least understands yum.__version__ but still
        # needs to get its repos and sacks set up manually.
        # Thus, we just try it, fail, and then try again. WCPGW?
        y.doRepoSetup()
        y.doSackSetup()
        db = y.doPackageLists('all')
    
    y.closeRpmDB()
  
  except Errors.YumBaseError, e:
    print >> sys.stderr, "Error! %s" % e 
    failure = True
    sys.exit(1)

# Ensure we clear the lock.
finally:
  try:
    y.doUnlock(PIDFILE)
  # Keep Unlock from raising a second exception as it does with a yum.conf 
  # config error.
  except Errors.YumBaseError:
    if failure == False: 
      print >> sys.stderr, "Error! %s" % e 
    sys.exit(1)
  
for pkg in db.installed:
     print '%s,installed,%s,%s,%s,%s' % ( pkg.name, 
                                          pkg.epoch,
                                          pkg.version,
                                          pkg.release,
                                          pkg.arch )
for pkg in db.available:
     print '%s,available,%s,%s,%s,%s' % ( pkg.name, 
                                          pkg.epoch,
                                          pkg.version,
                                          pkg.release,
                                          pkg.arch )

sys.exit(0)
