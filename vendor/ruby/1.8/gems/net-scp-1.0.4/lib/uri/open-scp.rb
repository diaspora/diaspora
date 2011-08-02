require 'open-uri'
require 'uri/scp'
require 'net/scp'

module URI

  class SCP
    def buffer_open(buf, proxy, open_options)
      options = open_options.merge(:port => port, :password => password)
      progress = options.delete(:progress_proc)
      buf << Net::SCP.download!(host, user, path, nil, open_options, &progress)
      buf.io.rewind
    end

    include OpenURI::OpenRead
  end

end
