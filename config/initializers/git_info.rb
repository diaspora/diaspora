#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

unless ENV['HEROKU']
  s = `git show --name-only 2>/dev/null || :`
  if (s.nil? or s.empty?)
       path =  File.expand_path("config/gitversion")
       begin
           if (File.exists?( path))
               s = ''
               f = File.open( path)
               f.each_line do |line|
                   s += line
               end
               f.close
           end
       rescue
           s = ""
       end
  end
  GIT_INFO = s
  # What's the scope of this s? Leave to GC just in case...
  s = nil
else
  GIT_INFO = nil
end
