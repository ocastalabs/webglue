module WebGlue

  class Config
    DEBUG             = true
    FEEDS_DIR         = (File.join(File.dirname(__FILE__), 'feeds')).freeze
    GIVEUP            = 10
    CHECK             = 300 # check every 5 min
    MIN_UPDATE_PERIOD = 300 # Allow a publisher to publish every 5th minute
  end

end
