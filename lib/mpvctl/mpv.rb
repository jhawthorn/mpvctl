require "mpvctl/socket"

module MpvCtl
  class Mpv
    attr_reader :socket

    def initialize
      @socket = Socket.new('/tmp/mpvsocket')
    end

    def play(path, mode=:replace)
      mode =
        case mode
        when :replace then 'replace'
        when :append then 'append-play'
        else raise ArgumentError, "unknown play mode"
        end
      command 'loadfile', path, mode
    end

    def seek(seconds, type)
      type =
        case type
        when :relative then 'relative'
        when :absolute then 'absolute'
        else raise ArgumentError, "unknown seek type"
        end
      command 'seek', seconds, type
    end

    def next
      command 'playlist-next'
    end

    def prev
      command 'playlist-prev'
    end

    def stop
      command 'stop'
    end

    def get_property(prop)
      command 'get_property', prop
    end

    def set_property(prop, value)
      command 'set_property', prop, value
    end

    def command(*args)
      socket.command *args
    end

    def close
      socket.close
    end
  end
end
