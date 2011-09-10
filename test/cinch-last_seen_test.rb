require 'rubygems'
gem 'minitest'
require 'minitest/spec'
require 'mocha'
require 'timecop'
require 'minitest/autorun'
require 'purdytest'
require File.expand_path('../../lib/cinch/plugins/last_seen',__FILE__)

alias :context :describe

describe 'cinch-last_seen' do
  def dont_register!
    Cinch::Plugins::LastSeen.stubs(:__register_with_bot).with(any_parameters).returns(true)
  end

  def log_message(chatroom = '#chatroom', nick = 'alice')
    @backend.expects(:record_time).with(chatroom, nick)
    @plugin.log_message(@message)
  end

  before do
    dont_register!
    Timecop.freeze(Time.now)
    @backend = mock("Backend")
    @bot = mock("Bot")
    @plugin = Cinch::Plugins::LastSeen.new(@bot)
    @config = mock("Config")
    @config.stubs("[]").with(:channels)
    @plugin.stubs(:config).returns(@config)
    @plugin.backend = @backend
    @user = mock("User")
    @user.stubs(:nick).returns('alice')
    @message = mock("Message")
    @message.stubs(:user).returns(@user)
    @message.stubs(:channel).returns("#chatroom")
  end

  after do
    Timecop.return
  end

  it "records when a nick says something" do
    @backend.expects(:record_time).with('#chatroom', 'alice')
    @plugin.log_message(@message)
  end

  it "tells you the last time a nick said something" do
    log_message
    @backend.expects(:get_time).with('#chatroom', 'alice').returns(Time.now)
    @message.expects(:reply).with("I've last seen alice at #{Time.now}", true)
    @plugin.check_nick(@message, 'alice')
  end

  it "updates the timestamp if the nick says something new" do
    log_message
    Timecop.freeze(Time.now.to_i + 300)
    log_message
    @backend.expects(:get_time).with('#chatroom', 'alice').returns(Time.now)
    @message.expects(:reply).with("I've last seen alice at #{Time.now}", true)
    @plugin.check_nick(@message, 'alice')
  end

  it "reports if it hasn't seen a user for the channel" do
    @message.stubs(:channel).returns("#foochat")
    @backend.expects(:get_time).with('#foochat', 'alice').returns(nil)
    @message.expects(:reply).with("I haven't seen alice, sorry.", true)
    @plugin.check_nick(@message, 'alice')
  end

  context "when included channels are specified" do
    before do
      @config.stubs("[]").with(:channels).returns(:include => "#chatroom")
    end

    it "records times for specified channels" do
      @backend.expects(:record_time).with('#chatroom', 'alice')
      @plugin.log_message(@message)
    end

    it "doesn't record times for unspecified channels" do
      @backend.expects(:record_time).never
      @message.stubs(:channel).returns("#foochat")
      @plugin.log_message(@message)
    end

    it "doesn't reply on unspecified channels" do
      @message.stubs(:channel).returns("#foochat")
      @message.expects(:reply).never
      @plugin.check_nick(@message, "alice")
    end
  end

  context "when excluded channels are specified" do
    before do
      @config.stubs("[]").with(:channels).returns(:exclude => "#chatroom")
    end

    it "records times for unspecified channels" do
      @backend.expects(:record_time).with('#foochat', 'alice')
      @message.stubs(:channel).returns("#foochat")
      @plugin.log_message(@message)
    end

    it "doesn't record times for specified channels" do
      @backend.expects(:record_time).never
      @plugin.log_message(@message)
    end

    it "doesn't reply on specified channels" do
      @message.expects(:reply).never
      @plugin.check_nick(@message, "alice")
    end
  end
end

