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
        else
          mpv.set_property('pause', false)
        end
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

    desc "raw CMD", "Issue a raw mpv IPC command to the socket"
    def raw(*command)
      with_mpv do |mpv|
        response = mpv.socket.command(*command)
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
      seek = :relative
      if seconds =~ /\A-(.*)\z/
        seconds = -Util.parse_time($1)
      elsif seconds =~ /\A\+(.*)\z/
        seconds = Util.parse_time($1)
      else
        seconds = Util.parse_time(seconds)
        seek = :absolute
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

    desc "stop", "Stops playback"
    def stop
      with_mpv do |mpv|
        mpv.stop
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
  end
end
