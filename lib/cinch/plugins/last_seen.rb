require 'cinch'

module Cinch
  module Plugins
    module LastSeen
      autoload :Base, File.expand_path('../last_seen/base.rb', __FILE__)
      autoload :RedisStorage, File.expand_path('../last_seen/storage/redis_storage.rb', __FILE__)
    end
  end
end
