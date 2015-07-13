require 'thor'
require 'mpvctl'

module MpvCtl
  class CLI < ::Thor
    class_option :verbose, type: :boolean, aliases: '-v'

    desc "play [FILE|URL]", "Play a file or URL. With no arguments this will unpause."
    def play(filename=nil)
      with_mpv do |mpv|
        if filename
          mpv.play abspath(filename)
        end
        mpv.set_property('pause', false)
      end
    end

    desc "wait", "Waits until the player is idle"
    def wait
      with_mpv do |mpv|
        mpv.wait_for_event('idle')
      end
    end

    desc "pause", "Pause the playback."
    def pause
      with_mpv do |mpv|
        mpv.set_property('pause', true)
      end
    end

    desc "add FILE|URL", "Append a file or URL to the current playlist"
    def add(filename)
      with_mpv do |mpv|
        mpv.play abspath(filename), :append
      end
    end

    desc "prev", "Switch to previous item in the playlist"
    def prev
      with_mpv { |mpv| mpv.prev }
    end

    desc "next", "Switch to next item in the playlist"
    def next
      with_mpv { |mpv| mpv.next }
    end

    desc "raw CMD", "Issue a raw mpv IPC command to the socket"
    def raw(*command)
      with_mpv do |mpv|
        response = mpv.command(*command)
        case response
        when nil
        when Array,Hash
          puts JSON.pretty_generate(response)
        else
          p response
        end
      end
    end

    desc "seek [+-]SECONDS", "Seeks by seconds."
    def seek(seconds)
      seek, seconds = parse_relative(seconds) do |time|
        Util.parse_time(time)
      end
      with_mpv do |mpv|
        mpv.seek(seconds, seek)
      end
    end

    desc "toggle", "Toggles between play and pause"
    def toggle
      with_mpv do |mpv|
        state = mpv.get_property('pause')
        mpv.set_property('pause', !state)
      end
    end

    desc "status", "Prints the current status"
    def status
      with_mpv do |mpv|
        idle = mpv.get_property('idle')
        if !idle
          puts "playing: \"#{mpv.get_property('media-title')}\""
          puts "path: #{mpv.get_property('path')}"
          puts "pause: #{mpv.get_property('pause')}"

          time_pos = mpv.get_property('time-pos')
          time_rem = mpv.get_property('time-remaining')
          puts "pos: #{Util.format_time time_pos}/#{Util.format_time time_pos+time_rem}"
        end
      end
    end

    desc "stop", "Stops playback and clears the playlist."
    def stop
      with_mpv do |mpv|
        mpv.stop
      end
    end

    desc "volume [VOLUME]", "Get or set volume"
    def volume(volume=nil)
      with_mpv do |mpv|
        if volume
          seek, volume = parse_relative(volume)
          if seek == :relative
            volume += mpv.get_property('volume')
          end

          # clamp volume to 0-100
          volume = [0, volume, 100].sort[1]

          mpv.set_property('volume', volume)
        end
        p mpv.get_property('volume')
      end
    end

    private
    def with_mpv
      MpvCtl.logger.level = Logger::DEBUG if options[:verbose]

      mpv = MpvCtl::Mpv.new
      yield mpv
    ensure
      mpv.close
    end

    def abspath(filename)
      if File.exists?(filename)
        File.expand_path(filename)
      else
        filename
      end
    end

    def parse_relative(s, &block)
      block ||= ->(s){ s.to_f }
      if s =~ /\A-(.*)\z/
        [:relative, -block.call($1)]
      elsif s =~ /\A\+(.*)\z/
        [:relative, block.call($1)]
      else
        [:absolute, block.call(s)]
      end
    end
  end
end
