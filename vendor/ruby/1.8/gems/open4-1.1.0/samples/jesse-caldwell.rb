#!/usr/bin/env ruby

require 'open4'
require 'pp'

# define a function we can call later. the function will take two
# arguments:
#     command   which we will run via open4 and be able to
#               send stdin as well as collect the pid, stderr and stdout.
#     input     optional data string to send to command on stdin
#
# this returns a hash of the command's pid, stderr, stdout, and status.
def run_cmd(command, input = nil)

 # we will use open4 in block form, which means that the variables
 # used inside the block will not be available once open4 has
 # finished. as long as variables are declared outside of the
 # block, they can be set inside the block and are available after
 # the block has finished.
 err = out = procid = status = verbose = nil

 # using a begin so we can use rescue later on.
 begin

   # run our command with open4 in block form.
   stat = Open4::popen4(command) do |pid, stdin, stdout, stderr|

     # the default behavior of ruby is to internally buffer I/O
     # ports when they are opened. open4 may not detect that stderr
     # and/or stdout has closed because ruby is helpfully buffering
     # the pipe for us. if open4 hangs, try uncommenting the next
     # two lines.
     # stderr.sync = true
     # stdout.sync = true

     # set procid to pid so we can see it outside of the block.
     procid = pid

     # if you want to use stdin, talk to stdin here. i tried it
     # with bc. generally i only need to capture output, not
     # interact with commands i'm running.
     stdin.puts input if input

     # stdin is opened write only. you'll raise an exception if
     # you try to read anything from it. here you can try to read
     # the first character from stdin.
     # stdin.gets(1)

     # now close stdin.
     stdin.close

     # make stderr and stdout available outside the block as well.
     # removing the read will return pointers to objects rather
     # than the data that the objects contain.
     out = stdout.read
     err = stderr.read

     # as stdin is write-only, stderr and stdout are read only.
     # you'll raise an exception if you try to write to either.
     # stderr.puts 'building appears to be on fire'

   # end of open4 block. pid, stdin, stdout and stderr are no
   # longer accessible.
   end

   # now outside of the open4 block, we can get the exit status
   # of our command by calling stat.exitstatus.
   status = stat.exitstatus

 # our function returns status from a command. however, if you
 # tell the function to run a command that does not exist, ruby
 # will raise an exception. we will trap that exception here, make
 # up a non-zero exit status, convert the ruby error to a string,
 # and populate err with it.
 rescue Errno::ENOENT => stderr
   status = 1
   err = stderr.to_s

 # handle null commands gracefully
 rescue TypeError => stderr
   status = 2
   err = 'Can\'t execute null command.'

 # done calling and/or rescuing open4.
 end

 # uncomment to make function print output.
 verbose = true

 # print the values if verbose is not nil.
 print "\n============================================================" if verbose
 print "\ncommand: #{ command }" if verbose
 print "\ninput  : \n\n#{ input }\n" if (verbose and input)
 print "\npid    : #{ procid }" if verbose
 print "\nstatus : #{ status }" if verbose
 print "\nstdout : #{ out }\n" if verbose
 print "\nstderr : #{ err }\n" if verbose
 print "============================================================\n" if verbose

 # now that (we think) we have handled everything, return a hash
 # with the process id, standard error, standard output, and the
 # exit status.
 return {
   :pid => procid,     # integer
   :stderr => err,     # string
   :stdout => out,     # string
   :status => status,  # integer
 }

 # return terminates function. code here will not run!
 print 'this will never show up.'

# end of run_cmd function.
end

# this will raise an exception which our function will trap,
# complaining that the command does not exist.
cmd = run_cmd('/bin/does/not/exist')

# something that will produce a fair amount of output. you do have
# an nmap source tree lying around, right?
cmd = run_cmd('cd nmap-5.51 ; ./configure')

# bc, to illustrate using stdin.
cmd = run_cmd('bc', "2^16\nquit")

# uncomment to see hash returned by run_cmd function.
# pp cmd

# test function with null command
cmd = run_cmd(nil)
