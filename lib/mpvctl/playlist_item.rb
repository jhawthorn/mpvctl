module MpvCtl
  class PlaylistItem
    attr_reader :filename, :current, :playing
    attr_reader :index, :mpv
    alias_method :current?, :current
    alias_method :playing?, :playing

    def initialize(mpv, index, attr = {})
      @mpv = mpv
      @index = index
      @filename = attr['filename']
      @current = !!attr['current']
      @playing = !!attr['playing']
    end
  end
end
