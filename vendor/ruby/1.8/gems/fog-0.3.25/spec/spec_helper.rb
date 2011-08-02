require 'spec'
require 'open-uri'
require 'fog'
Fog.bin = true
require 'fog/core/bin'
require 'fog/vcloud/bin'

if ENV["FOG_MOCK"] == "true"
  Fog.mock!
end

def eventually(max_delay = 16, &block)
  delays = [0]
  delay_step = 1
  total = 0
  while true
    delay = 1
    delay_step.times do
      delay *= 2
    end
    delays << delay
    delay_step += 1
    break if delay >= max_delay
  end
  delays.each do |delay|
    begin
      sleep(delay)
      yield
      break
    rescue => error
      raise error if delay >= max_delay
    end
  end
end

unless defined?(GENTOO_AMI)
  GENTOO_AMI = 'ami-5ee70037'
end

def lorem_file
  File.open(File.dirname(__FILE__) + '/lorem.txt', 'r')
end
