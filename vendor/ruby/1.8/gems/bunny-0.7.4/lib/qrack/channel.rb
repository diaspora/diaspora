# encoding: utf-8

module Qrack
  # Channel ancestor class
  class Channel

    attr_accessor :number, :active, :frame_buffer
    attr_reader :client

    def initialize(client)
      @frame_buffer = []
      @client = client
      @number = client.channels.size
      @active = false
      client.channels[@number] = self
    end

  end

end
