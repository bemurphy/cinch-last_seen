require 'redis'
require 'redis-namespace'

# TODO extract this into a gem so we can reuse across cinch plugins,
# or just general config a redis connection at toplevel for re-use

module Cinch
  module Plugins
    class LastSeen
      class RedisStorage
        def initialize
          @redis = ::Redis::Namespace.new "cinch-seen_last", :redis => Redis.new(:thread_safe => true)
        end

        # def []=(key, value)
        #   @redis.set key, Marshal.dump(value)
        # end

        # def [](key)
        #   value = @redis.get key
        #   Marshal.load(value) if value
        # end

        # def set_members(set)
        #   @redis.zrange(set.to_s, 0, -1)
        # end

        def record_time(set, key)
          @redis.zadd(set.to_s, Time.now.to_i, key.to_s)
        end

        def get_time(set, key)
          time = @redis.zscore(set, key)
          Time.at(time.to_i) if time
        end
      end
    end
  end
end
