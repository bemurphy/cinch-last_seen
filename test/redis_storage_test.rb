require File.expand_path('../test_helper' ,__FILE__)
require 'redis/namespace'

describe 'redis_storage' do
  before do
    @redis = mock("Redis")
    ::Redis::Namespace.stubs(:new).returns(@redis)
    @redis_storage = Cinch::Plugins::LastSeen::RedisStorage.new
    Timecop.freeze
  end

  after do
    Timecop.return
  end

  it "assigns redis" do
    assert @redis_storage.redis
  end

  it "records timestamps using a sorted set" do
    @redis.expects(:zadd).with("a:set:name", Time.now.to_i, "a_key")
    @redis_storage.record_time("a:set:name", "a_key")
  end

  it "gets times using the score from the sorted set" do
    epoch_seconds = 1315631451
    @redis.expects(:zscore).with("a:set:name", "a_key").returns(epoch_seconds.to_s)
    @redis_storage.get_time("a:set:name", "a_key").to_i.must_equal epoch_seconds
  end
end
