#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
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

class Chef
  module Mixin
    module Command
      module Unix
        # This is taken directly from Ara T Howard's Open4 library, and then
        # modified to suit the needs of Chef.  Any bugs here are most likely
        # my own, and not Ara's.
        #
        # The original appears in external/open4.rb in its unmodified form.
        #
        # Thanks Ara!
        def popen4(cmd, args={}, &b)

          # Waitlast - this is magic.
          #
          # Do we wait for the child process to die before we yield
          # to the block, or after?  That is the magic of waitlast.
          #
          # By default, we are waiting before we yield the block.
          args[:waitlast] ||= false

          args[:user] ||= nil
          unless args[:user].kind_of?(Integer)
            args[:user] = Etc.getpwnam(args[:user]).uid if args[:user]
          end
          args[:group] ||= nil
          unless args[:group].kind_of?(Integer)
            args[:group] = Etc.getgrnam(args[:group]).gid if args[:group]
          end
          args[:environment] ||= {}

          # Default on C locale so parsing commands output can be done
          # independently of the node's default locale.
          # "LC_ALL" could be set to nil, in which case we also must ignore it.
          unless args[:environment].has_key?("LC_ALL")
            args[:environment]["LC_ALL"] = "C"
          end

          pw, pr, pe, ps = IO.pipe, IO.pipe, IO.pipe, IO.pipe

          verbose = $VERBOSE
          begin
            $VERBOSE = nil
            ps.last.fcntl(Fcntl::F_SETFD, Fcntl::FD_CLOEXEC)

            cid = fork {
              pw.last.close
              STDIN.reopen pw.first
              pw.first.close

              pr.first.close
              STDOUT.reopen pr.last
              pr.last.close

              pe.first.close
              STDERR.reopen pe.last
              pe.last.close

              STDOUT.sync = STDERR.sync = true

              if args[:group]
                Process.egid = args[:group]
                Process.gid = args[:group]
              end

              if args[:user]
                Process.euid = args[:user]
                Process.uid = args[:user]
              end

              args[:environment].each do |key,value|
                ENV[key] = value
              end

              if args[:umask]
                umask = ((args[:umask].respond_to?(:oct) ? args[:umask].oct : args[:umask].to_i) & 007777)
                File.umask(umask)
              end

              begin
                if cmd.kind_of?(Array)
                  exec(*cmd)
                else
                  exec(cmd)
                end
                raise 'forty-two'
              rescue Exception => e
                Marshal.dump(e, ps.last)
                ps.last.flush
              end
              ps.last.close unless (ps.last.closed?)
              exit!
            }
          ensure
            $VERBOSE = verbose
          end

          [pw.first, pr.last, pe.last, ps.last].each{|fd| fd.close}

          begin
            e = Marshal.load ps.first
            raise(Exception === e ? e : "unknown failure!")
          rescue EOFError # If we get an EOF error, then the exec was successful
            42
          ensure
            ps.first.close
          end

          pw.last.sync = true

          pi = [pw.last, pr.first, pe.first]

          if b
            begin
              if args[:waitlast]
                b[cid, *pi]
                # send EOF so that if the child process is reading from STDIN
                # it will actually finish up and exit
                pi[0].close_write
                Process.waitpid2(cid).last
              else
                # This took some doing.
                # The trick here is to close STDIN
                # Then set our end of the childs pipes to be O_NONBLOCK
                # Then wait for the child to die, which means any IO it
                # wants to do must be done - it's dead.  If it isn't,
                # it's because something totally skanky is happening,
                # and we don't care.
                o = StringIO.new
                e = StringIO.new

                pi[0].close

                stdout = pi[1]
                stderr = pi[2]

                stdout.sync = true
                stderr.sync = true

                stdout.fcntl(Fcntl::F_SETFL, pi[1].fcntl(Fcntl::F_GETFL) | Fcntl::O_NONBLOCK)
                stderr.fcntl(Fcntl::F_SETFL, pi[2].fcntl(Fcntl::F_GETFL) | Fcntl::O_NONBLOCK)

                stdout_finished = false
                stderr_finished = false

                results = nil

                while !stdout_finished || !stderr_finished
                  begin
                    channels_to_watch = []
                    channels_to_watch << stdout if !stdout_finished
                    channels_to_watch << stderr if !stderr_finished
                    ready = IO.select(channels_to_watch, nil, nil, 1.0)
                  rescue Errno::EAGAIN
                  ensure
                    results = Process.waitpid2(cid, Process::WNOHANG)
                    if results
                      stdout_finished = true
                      stderr_finished = true
                    end
                  end

                  if ready && ready.first.include?(stdout)
                    line = results ? stdout.gets(nil) : stdout.gets
                    if line
                      o.write(line)
                    else
                      stdout_finished = true
                    end
                  end
                  if ready && ready.first.include?(stderr)
                    line = results ? stderr.gets(nil) : stderr.gets
                    if line
                      e.write(line)
                    else
                      stderr_finished = true
                    end
                  end
                end
                results = Process.waitpid2(cid) unless results
                o.rewind
                e.rewind
                b[cid, pi[0], o, e]
                results.last
              end
            ensure
              pi.each{|fd| fd.close unless fd.closed?}
            end
          else
            [cid, pw.last, pr.first, pe.first]
          end
        end

      end
    end
  end
end
