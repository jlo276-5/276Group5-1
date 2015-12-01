class GroupMembershipRequestsController < ApplicationController
  before_action :valid_request, only: [:approve, :reject]

  def new
    @group = Group.find_by(id: params[:group_id])
    if @group.nil?
      flash[:danger] = "Invalid Group ID Specified: #{params[:group_id]}"
      redirect_to groups_path
    elsif @group.institution != current_user.institution
      flash[:danger] = "You do not belong to that Group's Institution."
      redirect_to groups_path
    elsif !@group.limited
      flash[:warning] = "The specified Group does not require Join Approvals"
      redirect_to groups_path
    else
      @gmr = GroupMembershipRequest.new
    end
  end

  def create
    @gmr = GroupMembershipRequest.new(gmr_params)
    @gmr.user = current_user
    if @gmr.group.institution != current_user.institution
      flash[:danger] = "You do not belong to that Group's Institution."
      redirect_to groups_path
    elsif @gmr.save
      flash[:success] = "New Group Membership Request Created. It will be in review until approved by an Administrator."
      redirect_to groups_path
    else
      render 'new'
    end
  end

  def approve
    gmr = GroupMembershipRequest.find_by(id: params[:id])
    if current_user.adminOfGroup?(gmr.group)
      gm = GroupMembership.new(group: gmr.group, user: gmr.user)
      if gm.save
        flash[:success] = "Membership Request Approved"
        gmr.destroy
      else
        flash[:danger] = "Could not approve Membership Request"
      end
      redirect_to requests_group_path(gm.group)
    else
      flash[:danger] = "You are not allowed to do that."
      redirect_to gmr.group
    end
  end

  def reject
    gmr = GroupMembershipRequest.find_by(id: params[:id])
    if current_user.adminOfGroup?(gmr.group)
      gmr.destroy
      flash[:success] = "Membership Request Rejected"
      redirect_to requests_group_path(gmr.group)
    else
      flash[:danger] = "You are not allowed to do that."
      redirect_to gmr.group
    end
  end

  private

  def gmr_params
    params.require(:group_membership_request).permit(:group_id, :user_id, :request_message)
  end

  def valid_request
    gmr = GroupMembershipRequest.find_by(id: params[:id])
    if gmr.nil?
      flash[:danger] = "Invalid Membership Request"
      redirect_to groups_path
    end
  end
end
