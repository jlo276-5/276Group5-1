class GroupsController < ApplicationController
  before_action :verify_membership, only: [:show, :edit, :update, :destroy, :group_requests, :promote_member, :demote_member, :kick_member]
  before_action :group_admin, only: [:edit, :update, :destroy, :group_requests, :promote_member, :demote_member, :kick_member]
  before_action :valid_membership, only: [:promote_member, :demote_member, :kick_member]
  layout 'group', only: [:show, :edit, :group_members, :group_requests]

  def new
    @group = Group.new
  end

  def index
    if params[:sort_by] == "NAME"
      @groups = Group.paginate(page: params[:page], per_page: 25).order('name ASC')
    elsif params[:sort_by] == "NAME_DESC"
      @groups = Group.paginate(page: params[:page], per_page: 25).order('name DESC')
    else
      @groups = Group.paginate(page: params[:page], per_page: 25).order('created_at DESC')
    end
    @paginate = true
  end

  def search
    if !params[:search].blank?
      @groups = Group.where("lower(name) LIKE ?", "%#{params[:search].downcase}%").paginate(page: params[:page], per_page: 25).order('created_at ASC')
    else
      @groups = Group.paginate(page: params[:page], per_page: 25).order('created_at ASC')
    end
    render 'index'
  end

  def show
    @group = Group.find_by(id: params[:id])

    @chat_channel_type = 2;
    @post_channel_type = 2;
    @messages = Message.where(channel_type: @chat_channel_type, channel_id: @group.id).last(30)
    @posts = Post.where(channel_type: @post_channel_type, channel_id: @group.id).order('created_at DESC')
  end

  def group_members
    @group = Group.find_by(id: params[:id])
    @members = @group.group_memberships.paginate(page: params[:page], per_page: 25).order('created_at ASC')
  end

  def group_requests
    @group = Group.find_by(id: params[:id])
    @requests = @group.group_membership_requests.paginate(page: params[:page], per_page: 25).order('created_at ASC')
  end

  def promote_member
    gm = GroupMembership.find_by(id: params[:gm_id])
    if gm.role == 0
      gm.role += 1
      if gm.save
        flash[:success] = "Promoted #{gm.user.name} to Administrator in this Group"
        if gm.user.notification_emails
          GroupMailer.group_promoted(gm.user, gm.group, "Member", "Administrator").deliver_now
        end
      else
        flash[:danger] = "Could not promote #{gm.user.name}"
      end
    else
      flash[:danger] = "#{gm.user.name} is already an Administrator"
    end
    redirect_to users_group_path(gm.group)
  end

  def demote_member
    gm = GroupMembership.find_by(id: params[:gm_id])
    if gm.role == 1
      gm.role -= 1
      if gm.save
        if gm.group.admin_users.size == 0
          gm_n = gm.group.group_memberships.first
          gm_n.role = 1
          gm_n.save
          flash[:success] = "Demoted #{gm.user.name} to Member in this Group, set #{gm_n.user.name} as new Administrator."
        else
          flash[:success] = "Demoted #{gm.user.name} to Member in this Group"
        end
        if gm.user.notification_emails
          GroupMailer.group_demoted(gm.user, gm.group, "Administrator", "Member").deliver_now
        end
      else
        flash[:danger] = "Could not demote #{gm.user.name}"
      end
    else
      flash[:danger] = "#{gm.user.name} is not an Administrator"
    end
    redirect_to users_group_path(gm.group)
  end

  def kick_member
    gm = GroupMembership.find_by(id: params[:gm_id])
    if gm.destroy
      flash[:success] = "Kicked #{gm.user.name} from this Group"
      if gm.user.notification_emails
        GroupMailer.group_kicked(gm.user, gm.group).deliver_now
      end
    else
      flash[:danger] = "Could not kick #{gm.user.name}"
    end
    redirect_to users_group_path(Group.find_by(id: params[:id]))
  end

  def create
    @group = Group.new(group_params)
    @group.creator = current_user.name
    if @group.save
      @gm = GroupMembership.new(group: @group, user: current_user)
      @gm.role = 1
      @gm.save
      flash[:success] = "Group created. You are now the Administrator."
      redirect_to @group
    else
      render 'new'
    end
  end

  def edit
    @group = Group.find_by(id: params[:id])
  end

  def update
    @group = Group.find_by(id: params[:id])
    if @group.update_attributes(group_params)
      flash[:success] = "Group updated."
      redirect_to edit_group_path(@group)
    else
      render 'edit'
    end
  end

  def destroy
    @group = Group.find_by(id: params[:id])
    if @group.destroy
      Message.where(channel_type: '2', channel_id: @group.id).destroy_all
      Message.where(channel_type: '5', channel_id: @group.id).destroy_all
      flash[:success] = "Group Deleted"
      redirect_to groups_path
    else
      flash[:error] = "Could not delete Group"
      redirect_to @group
    end
  end

  private

  def group_params
    params.require(:group).permit(:name, :creator, :limited, :description)
  end

  def valid_membership
    @gm = GroupMembership.find_by(id: params[:gm_id])
    if @gm.nil?
      flash[:danger] = "No such Group Membership Exists"
      redirect_to users_group_path(Group.find_by(id: params[:id]))
    end
  end

  def verify_membership
    group = Group.find_by(id: params[:id])
    if group.nil?
      flash[:danger] = "No such group exists with an id #{params[:id]}"
      redirect_to groups_path
    elsif !current_user.memberOfGroup?(group)
      flash[:danger] = "You are not a member of this group yet."
      redirect_to groups_path
    end
  end

  def group_admin
    group = Group.find_by(id: params[:id])
    unless current_user.adminOfGroup?(group)
      flash[:danger] = "You are not an admininstrator of this group."
      redirect_to group
    end
  end
end
