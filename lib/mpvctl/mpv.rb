require "mpvctl/socket"

module MpvCtl
  class Mpv
    attr_reader :socket

    def initialize
      @socket = Socket.new('/tmp/mpvsocket')
    end

    def play(path)
      socket.command 'loadfile', path
    end

    def close
      socket.close
    end
  end
end
