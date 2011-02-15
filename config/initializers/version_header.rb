#original from https://github.com/jopper/diaspora
#modified by David Morley
require 'time'

module ModifiedHelper
  def last_modified
    git_last='git log -1 --pretty=format:"%cd"'
    filepath = Rails.root.join('tmp', '.last_pull')
    time_min = 60
    @header_name = "X-Git-Update"
    if File.writable?(filepath)
      begin
        mtime = File.mtime(filepath)
        last = IO.readlines(filepath).at(0)
      rescue Exception => e
        Rails.logger.info("Failed to read git status #{filepath}: #{e}")
      end
    end
    if (mtime.nil? || mtime < Time.now-time_min)
      last = `#{git_last}`
      begin
        f = File.open(filepath, 'w')
        f.puts(last)
        f.close
      rescue Exception => e
        Rails.logger.info("Failed to log git status #{filepath}: #{e}")
      end
    end
    last
      headers[@header_name] = "#{last}"
    end
end

