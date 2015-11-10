class GroupMailer < ApplicationMailer

  def joined_group(user, group)
    @user = user
    @group = group
    mail to: user.email, subject: "[StuHub] Joined Group #{group.name}"
  end

  def left_group(user, group)
    @user = user
    @group = group
    mail to: user.email, subject: "[StuHub] Left Group #{group.name}"
  end

  def group_promoted(user, group)
    @user = user
    @group = group
    mail to: user.email, subject: "[StuHub] Promoted in Group #{group.name}"
  end

  def group_demoted(user, group)
    @user = user
    @group = group
    mail to: user.email, subject: "[StuHub] Demoted in Group #{group.name}"
  end

  def group_kicked(user, group)
    @user = user
    @group = group
    mail to: user.email, subject: "[StuHub] Kicked from Group #{group.name}"
  end

end
