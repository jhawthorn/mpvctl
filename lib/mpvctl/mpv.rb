require "mpvctl/socket"
require "mpvctl/playlist_item"

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
      osd_command 'seek', seconds, type
    end

    def next(force=false)
      command 'playlist-next', (force ? 'force' : 'weak')
    end

    def prev(force=false)
      command 'playlist-prev', (force ? 'force' : 'weak')
    end

    def stop
      command 'stop'
    end

    def playlist
      get_property('playlist').map.with_index do |item, index|
        PlaylistItem.new(self, index+1, item)
      end
    end

    def toggle_property(prop)
      set_property(prop, !get_property(prop))
    end

    def get_property(prop)
      command 'get_property', prop
    end

    def get_property(prop)
      command 'get_property', prop
    end

    def set_property(prop, value)
      command 'set_property', prop, value
    end

    def wait_for_event(*events)
      socket.wait_for_event(*events)
    end

    def osd_command(*args)
      socket.command 'osd-msg-bar', *args
    end

    def command(*args)
      socket.command *args
    end

    def close
      socket.close
    end
  end
end
