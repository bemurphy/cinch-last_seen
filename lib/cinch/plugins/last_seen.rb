require 'cinch'

module Cinch
  module Plugins
    module LastSeen
      autoload :Base, File.expand_path('./lib/cinch/plugins/last_seen/base.rb')
      autoload :RedisStorage, File.expand_path('./lib/cinch/plugins/last_seen/storage/redis_storage.rb')
    end
  end
end
