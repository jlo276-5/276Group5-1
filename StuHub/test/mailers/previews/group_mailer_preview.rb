# Preview all emails at http://localhost:3000/rails/mailers/group_mailer
class GroupMailerPreview < ActionMailer::Preview

    def joined_group
      user = User.first
      group = Group.first
      GroupMailer.joined_group(user, group)
    end

    def left_group
      user = User.first
      group = Group.first
      GroupMailer.left_group(user, group)
    end

    def group_promoted
      user = User.first
      group = Group.first
      old_role = "Test"
      new_role = "Test2"
      GroupMailer.group_promoted(user, group, old_role, new_role)
    end

    def group_demoted
      user = User.first
      group = Group.first
      old_role = "Test"
      new_role = "Test2"
      GroupMailer.group_demoted(user, group, old_role, new_role)
    end

    def group_kicked
      user = User.first
      group = Group.first
      GroupMailer.group_kicked(user, group)
    end

end
