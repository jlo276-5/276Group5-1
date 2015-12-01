require 'test_helper'

class GroupMailerTest < ActionMailer::TestCase

    def setup
      @user = users(:michael)
      @group = groups(:groupone)
    end

    test "check joined email" do
      mail = GroupMailer.joined_group(@user, @group)
      assert_equal "[StuHub] Joined Group \"#{@group.name}\"", mail.subject
      assert_equal [@user.email], mail.to
      assert_equal ["noreply@example.com"], mail.from
    end

    test "check dropped email" do
      mail = GroupMailer.left_group(@user, @group)
      assert_equal "[StuHub] Left Group \"#{@group.name}\"", mail.subject
      assert_equal [@user.email], mail.to
      assert_equal ["noreply@example.com"], mail.from
    end

    test "check promoted email" do
      mail = GroupMailer.group_promoted(@user, @group, "Member", "Administrator")
      assert_equal "[StuHub] Promoted in Group \"#{@group.name}\"", mail.subject
      assert_equal [@user.email], mail.to
      assert_equal ["noreply@example.com"], mail.from
      assert_match "Administrator", mail.body.encoded
    end

    test "check demoted email" do
      mail = GroupMailer.group_demoted(@user, @group, "Administrator", "Member")
      assert_equal "[StuHub] Demoted in Group \"#{@group.name}\"", mail.subject
      assert_equal [@user.email], mail.to
      assert_equal ["noreply@example.com"], mail.from
      assert_match "Member", mail.body.encoded
    end

    test "check kicked email" do
      mail = GroupMailer.group_kicked(@user, @group)
      assert_equal "[StuHub] Kicked from Group \"#{@group.name}\"", mail.subject
      assert_equal [@user.email], mail.to
      assert_equal ["noreply@example.com"], mail.from
    end

  end
