require 'thor'
require 'mpvctl'

module MpvCtl
  class CLI < ::Thor
    desc "play FILE|URL", "Play a file or URL"
    def play(filename)
      with_mpv do |mpv|
        mpv.play abspath(filename)
      end
    end

    desc "raw CMD", "Issue a raw mpv IPC command to the socket"
    def raw(*command)
      with_mpv do |mpv|
        mpv.socket.command(*command)
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

    private
    def with_mpv
      mpv = MpvCtl::Mpv.new
      yield mpv
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
