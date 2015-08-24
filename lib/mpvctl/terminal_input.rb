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
      MpvCtl.logger.info "Received keypress #{Curses.keyname(c)}"
      case c
      when Curses::Key::UP
        key 'UP'
        @mpv.seek(120, :relative)
      when Curses::Key::DOWN
        key 'DOWN'
        @mpv.seek(-120, :relative)
      when Curses::Key::LEFT
        key 'LEFT'
        @mpv.seek(-20, :relative)
      when Curses::Key::RIGHT
        key 'RIGHT'
        @mpv.seek(20, :relative)
      when Curses::Key::ENTER, 10
        key 'ENTER'
      when Curses::Key::BACKSPACE
        key 'BACKSPACE'
      when 3, 27 # Ctrl+c and ESC
        @done = true
      when 1..26
        key "Ctrl+#{(c + 'a'.ord - 1).chr}"
      when 'a'..'z', 'A'..'Z', '0'..'9'
        key c
      when ' '..'~'
        key c
      else
        puts "Unhandled key #{Curses.keyname(c)}"
      end
    end

    private

    def key(c)
      #@mpv.command('keypress', c)
    end

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
