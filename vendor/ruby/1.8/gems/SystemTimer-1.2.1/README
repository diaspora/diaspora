Synopsis
========

System Timer, a timer based on underlying `SIGALRM` system timers, is a
solution to Ruby processes which hang beyond the time limit when accessing
external resources. This is useful when `timeout.rb`, which, on M.R.I 1.8,
relies on green threads, does not work consistently.

More background on:

* [http://ph7spot.com/musings/system-timer](http://ph7spot.com/musings/system-timer)
* [http://davidvollbracht.com/2008/6/2/30-days-of-teach-day-1-systemtimer](http://davidvollbracht.com/2008/6/2/30-days-of-teach-day-1-systemtimer)

Usage 
=====

    require 'system_timer'
  
    SystemTimer.timeout_after(5) do
  
      # Something that should be interrupted if it takes too much time...
      # ... even if blocked on a system call!
  
    end

 Timeouts as Floats
 ------------------

  You can use a floating point number when specifying the timeout in
  seconds but SystemTimer will not allow you to go below 200ms, e.g.

    SystemTimer.timeout_after(0.5) do 
      # timeout after 500ms
    end

    SystemTimer.timeout_after(0.01) do 
      # timeout after (uncompressable) 200ms even if 10ms is requested
    end

  Note that SystemTimer is going through too many layers to be 
  able to reliably guarantee a sub-second timeout on all platforms, 
  so your mileage may vary when specifying timeouts under one second.

 Custom Timeout Exceptions
 -------------------------

  You can also use a custom timeout exception to be raised on timeouts (to
  avoid interference with other libraries using `Timeout::Error` -- e.g. `Net::HTTP`)

    require 'system_timer'
 
    begin

      SystemTimer.timeout_after(5, MyCustomTimeoutException) do
    
        # Something that should be interrupted if it takes too much time...
        # ... even if blocked on a system call!
    
      end

    rescue MyCustomTimeoutException => e
      # Recovering strategy
    end


Requirements
============

SystemTimer only works on UNIX platforms (Mac OS X, Linux, Solaris, BSD, ...).
You can install the gem on Microsoft Windows, but you will only get 
a convenience shell wrapping a simple call to timeout.rb under the cover.

Install
=======

    sudo gem install SystemTimer

Authors
=======

* David Vollbracht  <http://davidvollbracht.com>
* Philippe Hanrigou <http://ph7spot.com>

Contributors
============

* Dmytro Shteflyuk <http://kpumuk.info/> :
   - Changed from using Mutex to Monitor. Evidently Mutex causes thread
     join errors when Ruby is compiled with -disable-pthreads
     <http://github.com/kpumuk/system-micro-timer/commit/fe28f4dcf7d4126e53b7c642c5ec35fe8bc1e081>
   - First tentative to support float timeouts
     <http://github.com/kpumuk/system-micro-timer/commit/57fff73849aad7c94f8b9234352b7288d1314d21>

* runix <http://github.com/runix> :
   - Added support for custom timeout exception. Useful to avoid interference
     with other libraries using `Timeout::Error` (e.g. `Net::HTTP`)
     <http://github.com/runix/system-timer/commit/d33acb3acc53d5105c68b25c3a2126fa682f12c0>
     <http://github.com/runix/system-timer/commit/d8ca3452e462ea909d8e11a6091e7c30dfa3a1a8>

Copyright
=========

Copyright:: (C) 2008-2010  David Vollbracht & Philippe Hanrigou

Description
===========

While deploying Rails application in production our team discovered
that some web service call would not timeout way beyond their defined
limit, progressively freezing our Mongrel cluster until we restarted
the servers. A closer analysis revealed that the native thread in charge of
of the web service call was never scheduled, "stucked" on the service
call. As it turn out the timeout library bundled with Ruby 1.8 (MRI)
relies on green-threads to perform its magic... so the magic had no chance
to happen in this scenario.

Based on an original idea by Kurtis Seebaldt <http://kseebaldt.blogspot.com>,
David Vollbracht and Philippe Hanrigou pair programmed an alternative
implementation based on system timers (the +SIGALRM+ POSIX signal):
This design guarantees proper timeout behavior even when crossing-boundaries and accessing
system/external resources. Special care has been taken to interfere as little as
possible with other processes that might also rely on +SIGALRM+, 
in particular MySQL.

This implementation is not intended to be drop-in replacement to
timeout.rb, just a way to wrap sensitive call to system resources.   

You can find more details on SystemTimer and how to use it 
at http://ph7spot.com/articles/system_timer 

License
=======

(The Ruby License)

Copyright:: (C) 2008-2010  David Vollbracht & Philippe Hanrigou

SystemTimer is copyrighted free software by David Vollbracht and Philippe Hanrigou.
You can redistribute it and/or modify it under either the terms of the GPL
(see COPYING file), or the conditions below:

  1. You may make and give away verbatim copies of the source form of the
     software without restriction, provided that you duplicate all of the
     original copyright notices and associated disclaimers.

  2. You may modify your copy of the software in any way, provided that
     you do at least ONE of the following:

    a) place your modifications in the Public Domain or otherwise
       make them Freely Available, such as by posting said
       modifications to Usenet or an equivalent medium, or by allowing
       the author to include your modifications in the software.

    b) use the modified software only within your corporation or
       organization.

    c) rename any non-standard executables so the names do not conflict
       with standard executables, which must also be provided.

    d) make other distribution arrangements with the author.

  3. You may distribute the software in object code or executable
     form, provided that you do at least ONE of the following:

    a) distribute the executables and library files of the software,
       together with instructions (in the manual page or equivalent)
       on where to get the original distribution.

    b) accompany the distribution with the machine-readable source of
       the software.

    c) give non-standard executables non-standard names, with
       instructions on where to get the original software distribution.

    d) make other distribution arrangements with the author.

  4. You may modify and include the part of the software into any other
     software (possibly commercial).  But some files in the distribution
     are not written by the author, so that they are not under this terms.

     They are gc.c(partly), utils.c(partly), regex.[ch], st.[ch] and some
     files under the ./missing directory.  See each file for the copying
     condition.

  5. The scripts and library files supplied as input to or produced as 
     output from the software do not automatically fall under the
     copyright of the software, but belong to whomever generated them, 
     and may be sold commercially, and may be aggregated with this
     software.

  6. THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
     IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
     WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
     PURPOSE.


