require 'test_helper'

class PostTest < ActiveSupport::TestCase

  def setup
    @post = Post.new(user: users(:superman), channel_id: 2, channel_type: 2, body: "QWERTYUIOP")
  end

  test "should be valid" do
    assert @post.valid?
  end

  test "should have user" do
    @post.user = nil
    assert_not @post.valid?
  end

end
