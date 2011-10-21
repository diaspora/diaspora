require File.join(Rails.root, 'lib', 'stream', 'multi')

class MultisController < ApplicationController
  def index
    default_stream_action(Stream::Multi)
  end
end
