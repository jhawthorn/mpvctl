require 'curses'

module MpvCtl
  class TerminalInput
    def initialize(mpv)
      @mpv = mpv
      @done = false
    end

    def run
      open do
        until @done
          c = Curses.getch
          handle_key(c) if c
        end
      end
    end

    def handle_key(c)
      MpvCtl.logger.info "Received keypress #{Curses.keyname(c)}"
      p c
      case c
      when Curses::Key::UP
        @mpv.seek(120, :relative)
      when Curses::Key::DOWN
        @mpv.seek(-120, :relative)
      when Curses::Key::LEFT
        @mpv.seek(-20, :relative)
      when Curses::Key::RIGHT
        @mpv.seek(20, :relative)
      when Curses::Key::ENTER, 10
        @mpv.next(true)
      when '>'
        @mpv.next
      when '<'
        @mpv.prev
      when ' '
        @mpv.toggle_property('pause')
      when 3, 27 # Ctrl+c and ESC
        @done = true
      else
        puts "Unhandled key #{Curses.keyname(c)}"
      end
    rescue MpvCtl::Socket::Error => e
      puts "#{e}"
    end

    private

    def open(&block)
      Curses.noecho
      Curses.stdscr.keypad(true)
      Curses.raw
      Curses.init_screen
      yield self
    ensure
      Curses.clear
      Curses.close_screen
    end
  end
end
