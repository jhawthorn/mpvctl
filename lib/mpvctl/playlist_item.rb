module MpvCtl
  class PlaylistItem
    attr_reader :filename, :current, :playing
    alias_method :current?, :current
    alias_method :playing?, :playing

    def initialize(mpv, attr = {})
      @filename = attr['filename']
      @current = !!attr['current']
      @playing = !!attr['playing']
    end
  end
end
