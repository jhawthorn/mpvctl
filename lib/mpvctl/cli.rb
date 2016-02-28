require 'thor'
require 'mpvctl'
require 'mpvctl/terminal_input'
require 'pathname'

module MpvCtl
  class CLI < ::Thor
    class_option :verbose, type: :boolean, aliases: '-v'

    desc "play [FILE|URL]", "Play a file or URL. With no arguments this will unpause."
    class_option :wait, type: :boolean, aliases: '-w'
    class_option :input, type: :boolean, aliases: '-i'
    class_option :shuffle, type: :boolean, aliases: '-R'
    def play(*filenames)
      with_mpv do |mpv|
        if filenames.any?
          mpv.stop
          mpv.wait_for_idle

          filenames = abspaths(filenames)
          filenames.shuffle! if options[:shuffle]
          filenames.each do |filename|
            mpv.add filename
          end
          mpv.wait_for_event('tracks-changed')

          if options[:input]
            TerminalInput.new(mpv).run
          end

          if options[:wait]
            mpv.wait_for_idle
          end
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
        mpv.add abspath(filename)
      end
    end

    desc "prepend FILE|URL", "Prepend a file or URL to the current playlist and begin playing"
    def prepend(filename)
      with_mpv do |mpv|
        mpv.add abspath(filename)
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

    desc "input", "Send read STDIN as keyboard input to mpv"
    def input
      with_mpv do |mpv|
        TerminalInput.new(mpv).run
      end
    end

    desc "playlist", "Show the current playlist"
    def playlist
      with_mpv do |mpv|
        mpv.playlist.each do |item|
          puts "#{item.playing?? '*' : ' '} %2i %s" % [item.index, item.filename]
        end
      end
    end

    desc "logs", "show logs from running mpv"
    def logs
      with_mpv do |mpv|
        mpv.socket.watch do |json|
          p json
        end
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

    def abspaths(filenames)
      paths = []
      filenames.each do |root|
        if root =~ %r{\A(https?|rtmp)://}
          paths << root
        else
          Pathname(root).find do |path|
            paths << abspath(path) if path.file?
          end
        end
      end
      paths
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
