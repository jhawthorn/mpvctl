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

    def seek(seconds, type)
      type =
        case type
        when :relative then 'relative'
        when :absolute then 'absolute'
        else raise ArgumentError, "unknown seek type"
        end
      socket.command 'seek', seconds, type
    end

    def get_property(prop)
      socket.command('get_property', prop)
    end

    def set_property(prop, value)
      socket.command('set_property', prop, value)
    end

    def close
      socket.close
    end
  end
end
