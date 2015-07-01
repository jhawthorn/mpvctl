require 'socket'
require 'json'

module MpvCtl
  class Socket
    attr_reader :socket

    def initialize(path)
      @socket = UNIXSocket.new(path)
    end

    def command(*args)
      payload = JSON.dump({ "command" => args })
      puts payload
      socket.puts(payload)
      response = socket.readline
      puts response
      JSON.parse(response)
    end

    def watch
      loop do
        line = socket.readline
        yield JSON.parse(line)
      end
    end

    def close
      @socket.close
    end
  end
end
