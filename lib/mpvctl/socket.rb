require 'socket'
require 'json'

module MpvCtl
  class Socket
    class Error < StandardError
    end

    attr_reader :socket

    def initialize(path)
      @socket = UNIXSocket.new(path)
    end

    def command(*args)
      payload = JSON.dump({"command" => args})

      send(payload)
      response = recv

      parse_response(response)
    end

    def watch
      loop do
        yield JSON.parse(recv)
      end
    end

    def close
      @socket.close
    end

    private
    def send(line)
      MpvCtl.logger.debug "SEND: #{line}"
      socket.puts(line)
    end

    def recv
      line = socket.readline.strip
      MpvCtl.logger.debug "RECV: #{line}"
      line
    end

    def parse_response(json)
      response = JSON.parse(json)
      if response['error'] == 'success'
        response['data']
      else
        raise Error, response['error']
      end
    end

  end
end
