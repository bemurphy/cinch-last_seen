require 'cinch'

module Cinch
  module Plugins
    class LastSeen
      attr_accessor :backend

      include Cinch::Plugin

      autoload :RedisStorage, File.expand_path('./lib/cinch/plugins/last_seen/storage/redis_storage.rb')

      def initialize(*args)
        super
        # TODO config this
        self.backend = RedisStorage.new
      end

      listen_to :channel, :method => :log_message

      def log_message(m)
        return unless log_channel?(m.channel)
        backend.record_time m.channel, m.user.nick
      end

      match /seen (.+)/, :method => :check_nick

      def check_nick(m, nick)
        if time = backend.get_time(m.channel, nick)
          readable_time = Time.at time.to_i
          m.reply "I've last seen #{nick} at #{readable_time}", true
        else
          m.reply "I haven't seen #{nick}, sorry.", true
        end
      end

      private

      def log_channel?(channel)
        channel = channel.to_s
        our_config = config[:channels] || {}

        if our_config[:include]
          our_config[:include].include?(channel)
        elsif our_config[:exclude]
          !our_config[:exclude].include?(channel)
        else
          true
        end
      end
    end
  end
end
