class GroupMembershipsController < ApplicationController
  before_action :valid_gm, only: [:destroy]
  before_action :correct_user, only: [:destroy]

  def create
    group = Group.find(params[:group_id])
    user = User.find(params[:user_id])
    if !user.groups.find_by(id: group.id).nil?
      flash[:warning] = "You are already a member of this group."
      redirect_to group_path(group)
    elsif group.limited
      flash[:info] = "This Group requires Join Approvals."
      redirect_to new_gm_request_path(group_id: group.id, user_id: user.id)
    else
      @gm = GroupMembership.new(group: group, user: user)
      if @gm.save
        flash[:success] = "Group Membership Created"
        redirect_to group_path(group)
      else
        flash[:danger] = "Could not create Group Membership"
        redirect_to groups_path
      end
    end
  end

  def destroy
    gm = GroupMembership.find(params[:id])
    gm.destroy
    if gm.group.group_memberships.size == 0
      gm.group.destroy
      flash[:success] = "The Group #{gm.group.name} was deleted because there were no more members left."
    elsif gm.group.admin_users.size == 0
      gm_n = gm.group.group_memberships.first
      gm_n.role = 1
      gm_n.save
      flash[:success] = "Left Group #{gm.group.name}, set #{gm_n.user.name} as new Administrator."
    else
      flash[:success] = "Left Group #{gm.group.name}"
    end
    redirect_to groups_path
  end

  private

  def valid_gm
    @gm = GroupMembership.find_by(id: params[:id])
    if @gm.nil?
      flash[:danger] = "No such Group Membership Exists"
      redirect_to home_path
    end
  end

  def correct_user
    @gm = GroupMembership.find_by(id: params[:id])
    unless (current_user?(@gm.user) or current_user.more_powerful(true, gm.user))
      flash[:danger] = "You do not have the permission to do that."
      redirect_to groups_path
    end
  end
end
