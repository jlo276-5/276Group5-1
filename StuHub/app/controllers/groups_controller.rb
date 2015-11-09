class GroupsController < ApplicationController
  before_action :valid_group, only: [:show, :edit, :update, :destroy]
  before_action :verify_membership, only: [:show, :edit, :update, :destroy]
  before_action :group_owner, only: [:destroy]
  before_action :group_admin, only: [:edit, :update]

  def new
    @group = Group.new
  end

  def index
    @groups = Group.paginate(page: params[:page], per_page: 25).order('created_at ASC')
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
    @post_channel_type = 5;
    @messages = Message.where(channel_type: @chat_channel_type, channel_id: @group.id).last(30)
    @posts = Message.where(channel_type: @post_channel_type, channel_id: @group.id).last(30)
  end

  def group_members
    @group = Group.find_by(id: params[:id])
    @users = @group.users.paginate(page: params[:page], per_page: 25).order('created_at ASC')
  end

  def create
    @group = Group.new(group_params)
    @group.creator = current_user.name
    if @group.save
      @group.users << current_user
      flash[:info] = "Group created."
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
      redirect_to @group
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

  def verify_membership
    group = Group.find_by(id: params[:id])
    if group and !current_user.memberOfGroup?(group)
      flash[:danger] = "You are not a member of this group yet."
      redirect_to groups_path
    end
  end

  def group_admin
    unless false

    end
  end

  def group_owner
    unless false

    end
  end

  def valid_group
    @group = Group.find_by(id: params[:id])
    if @group.nil?
      flash[:danger] = "No such group exists with an id #{params[:id]}"
      redirect_to groups_path
    end
  end
end
