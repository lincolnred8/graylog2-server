require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  should "have few time fields" do
    message = Message.make

    assert_kind_of(Float, message.created_at)
    assert !message.respond_to?(:timestamp), "Do not define method like this."
    assert !message.respond_to?(:date), "Do not define method like this."
    assert !message.respond_to?(:time), "Do not define method like this."
  end

  context "creation time" do
    setup do
      @message = Message.make
    end

    should "be returned in request's timezone" do
      assert_in_delta(Time.now.utc.to_f, @message.created_at, 3.0)

      assert_equal 'UTC', Time.zone.name, "Please do not change default timezone"
      assert_equal Time.zone.name, @message.created_at_time.zone
      assert_equal Time.zone.at(@message.created_at),  @message.created_at_time

      Time.zone = "TOT"
      assert_equal Time.zone.name, @message.created_at_time.zone
      assert_equal Time.zone.at(@message.created_at),  @message.created_at_time
    end
  end

  should "always return message" do
    message = Message.make(:message => nil)  # due to a bug in server, for example
    assert_equal '', message.message
  end

  should "return file and line without absent values" do
    assert_equal 'foo.rb:42', Message.make(:file => 'foo.rb', :line => 42).file_and_line
    assert_equal 'foo.rb',    Message.make(:file => 'foo.rb', :line => nil).file_and_line
    assert_equal '',          Message.make(:file => nil,      :line => nil).file_and_line
  end

  should "test count_of_hostgroup" do
    Host.make(:host => "somehost").save

    Message.make(:host => "foobar", :message => "bla").save
    Message.make(:host => "foobarish", :message => "gdfgdfhh").save
    Message.make(:host => "foofoo", :message => "foobarish").save
    Message.make(:host => "somehost", :message => "gdfgfdd").save
    Message.make(:host => "somehost", :message => "wat").save
    Message.make(:host => "anotherhost", :message => "foobar").save
    Message.make(:host => "anotherfoohost", :message => "don't match me").save

    hostgroup = Hostgroup.find(3)
    assert_equal 5, Message.count_of_hostgroup(hostgroup)
  end

  should "find additional fields" do
    message = Message.make(:host => "local", :message => "hi!", :_foo => "bar", :_baz => "1", :invalid => "123")
    assert message.additional_fields?
    assert_equal({'foo' => 'bar', 'baz' => '1'}, message.additional_fields)
  end
end
