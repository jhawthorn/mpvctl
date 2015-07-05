module MpvCtl
  module Util
    extend self

    TIME_REGEXPS = [
      /\A(?<seconds>\d+)\z/,
      /\A(?<minutes>\d+):(?<seconds>\d\d)\z/,
      /\A(?<hours>\d+):(?<minutes>\d\d):(?<seconds>\d\d)\z/,
      /\A((?<hours>\d+)h)?((?<minutes>\d+)m)?((?<seconds>\d+)s?)?\z/
    ]

    # Parse a time string to an integer in seconds
    def parse_time(string)
      return nil if string.empty?
      TIME_REGEXPS.each do |regex|
        if match = regex.match(string)
          hours   = Integer(match.names.include?('hours')   && match[:hours]   || 0)
          minutes = Integer(match.names.include?('minutes') && match[:minutes] || 0)
          seconds = Integer(match.names.include?('seconds') && match[:seconds] || 0)
          return hours*60*60 + minutes*60 + seconds
        end
      end
      nil
    end

    def format_time(seconds)
      seconds = seconds.to_i
      minutes = seconds / 60
      hours = minutes / 60
      seconds %= 60
      minutes %= 60

      "%i:%.2i:%.2i" % [hours, minutes, seconds]
    end
  end
end
