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
      MpvCtl.logger.debug payload
      socket.puts(payload)
      response = socket.readline
      MpvCtl.logger.debug response
      parse_response(response)
    end

    def parse_response(json)
      response = JSON.parse(json)
      if response['error'] == 'success'
        response['data']
      else
        raise Error, response['error']
      end
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
