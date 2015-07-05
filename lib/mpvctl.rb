require "mpvctl/version"
require "mpvctl/socket"
require "mpvctl/mpv"
require "mpvctl/util"

require 'logger'
module MpvCtl
  class << self
    attr_accessor :logger
  end
  self.logger = Logger.new(STDOUT)
  self.logger.level = Logger::INFO
end
