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

      watch do |response|
        if response['error']
          return parse_response(response)
        end
      end
    end

    def wait_for_event(name)
      watch do |response|
        if response['event'] == name
          return response
        end
      end
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

    def parse_response(response)
      if response['error'] == 'success'
        response['data']
      else
        raise Error, response['error']
      end
    end
  end
end
