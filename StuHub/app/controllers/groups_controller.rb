class GroupsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  before_action :verify_membership, only: [:show, :edit, :update, :destroy, :group_members, :group_requests, :promote_member, :demote_member, :kick_member, :resources, :new_resource, :create_resource, :get_resource, :edit_resource, :update_resource, :destroy_resource]
  before_action :group_admin, only: [:edit, :update, :destroy, :group_requests, :promote_member, :demote_member, :kick_member]
  before_action :valid_membership, only: [:promote_member, :demote_member, :kick_member]
  before_action :valid_dropbox, only: [:new_resource, :create_resource]
  before_action :valid_resource, only: [:get_resource, :edit_resource, :update_resource, :destroy_resource]
  before_action :can_edit_resource, only: [:edit_resource, :update_resource, :destroy_resource]
  after_action :update_last_visited, only: [:show, :edit, :group_members, :group_requests, :resources, :new_resource, :get_resource, :edit_resource]
  layout 'group', only: [:show, :edit, :group_members, :group_requests, :resources, :new_resource, :create_resource, :edit_resource, :update_resource, :destroy_resource]

  def new
    @group = Group.new
  end

  def index
    if params[:sort_by] == "NAME"
      @groups = current_user.institution.groups.paginate(page: params[:page], per_page: 25).order('name ASC')
    elsif params[:sort_by] == "NAME_DESC"
      @groups = current_user.institution.groups.paginate(page: params[:page], per_page: 25).order('name DESC')
    else
      @groups = current_user.institution.groups.paginate(page: params[:page], per_page: 25).order('created_at DESC')
    end
    @paginate = true
  end

  def search
    if !params[:search].blank?
      @groups = current_user.institution.groups.where("lower(name) LIKE ?", "%#{params[:search].downcase}%").paginate(page: params[:page], per_page: 25).order('created_at ASC')
    else
      @groups = current_user.institution.groups.paginate(page: params[:page], per_page: 25).order('created_at ASC')
    end
    render 'index'
  end

  def show
    @group = Group.find_by(id: params[:id])

    @chat_channel_type = 2;
    @post_channel_type = 2;
    @messages = Message.includes(:user).where(channel_type: @chat_channel_type, channel_id: @group.id).last(30)
    @posts = Post.includes(:user).where(channel_type: @post_channel_type, channel_id: @group.id).order('created_at DESC')
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
    @group.institution = current_user.institution
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

  def resources
    @group = Group.find_by(id: params[:id])
    @resources = GroupResource.where(group_id: params[:id])
  end

  def new_resource
    @group = Group.find_by(id: params[:id])
    @resource = GroupResource.new
  end

  def create_resource
    @group = Group.find_by(id: params[:id])
    @resource = GroupResource.new(resource_params)
    client = Dropbox::API::Client.new(token: current_user.dropbox_token, secret: current_user.dropbox_secret)

    if client.nil?
      flash[:danger] = "Invalid Connection to Dropbox. Please relink your account."
      redirect_to accounts_user_path(current_user)
    elsif params[:group_resource][:file].blank?
      @resource.errors.add(:base, "You must attach a file.")
      render 'new_resource'
    elsif !Resource.permitted_types.include?(params[:group_resource][:file].content_type)
      @resource.errors.add(:base, 'Files of this type are not permitted')
      render 'new_resource'
    else
      @resource.file_name = params[:group_resource][:file].original_filename
      @resource.content_type = params[:group_resource][:file].content_type
      @resource.group = @group
      @resource.user = current_user
      existing = nil
      begin
        client.find("GroupResources")
      rescue Dropbox::API::Error::NotFound
        client.mkdir("GroupResources")
      end
      begin
        existing = client.find("GroupResources/#{@resource.file_name}")
      rescue Dropbox::API::Error::NotFound
        existing = nil
      end
      begin
        if existing.nil? && (file = client.chunked_upload("GroupResources/#{@resource.file_name}", params[:group_resource][:file].tempfile)) && @resource.save
          p file
          flash[:success] = "New Group Resource Created: File \"#{@resource.file_name}\", Size #{number_to_human_size(file.bytes)}"
          redirect_to resources_group_path(@group)
        elsif !existing.nil?
          @resource.errors.add(:base, "There is already a file named #{@resource.file_name} in your Dropbox. Please name it something different.")
          render 'new_resource'
        else
          render 'new_resource'
        end
      rescue Dropbox::API::Error => e
        @resource.errors.add(:base, "Could not upload to Dropbox: #{e.message}.")
        render 'new_resource'
      end
    end
  end

  def get_resource
    @group = Group.find_by(id: params[:id])
    @resource = GroupResource.find_by(id: params[:resource_id])

    client = Dropbox::API::Client.new(token: @resource.user.dropbox_token, secret: @resource.user.dropbox_secret)

    if client.nil?
      flash[:danger] = "That Resource is no longer available."
      @resource.destroy
      redirect_to resources_group_path(@group)
    else
      begin
        file = client.find("GroupResources/#{@resource.file_name}")
        redirect_to file.share_url.url
      rescue Dropbox::API::Error => e
        flash[:danger] = "That Resource is no longer available."
        @resource.destroy
        redirect_to resources_group_path(@group)
      end
    end
  end

  def edit_resource
    @group = Group.find_by(id: params[:id])
    @resource = GroupResource.find_by(id: params[:resource_id])
  end

  def update_resource
    @group = Group.find_by(id: params[:id])
    resource = GroupResource.find_by(id: params[:resource_id])
    if !params[:group_resource][:file].blank?
      @resource.errors.add(:base, "You cannot change the file that the Resource points to. Please create a new Resource.")
      render 'edit_resource'
    elsif resource.update_attributes(resource_params)
      flash[:success] = "Resource Updated"
      redirect_to resources_group_path(@group)
    else
      render 'edit_resource'
    end
  end

  def destroy_resource
    @group = Group.find_by(id: params[:id])
    resource = GroupResource.find_by(id: params[:resource_id])
    client = Dropbox::API::Client.new(token: resource.user.dropbox_token, secret: resource.user.dropbox_secret)
    if resource.destroy
      if resource.file_name.blank? or client.nil?
        flash[:warning] = "Resource Deleted, but could not delete file from Dropbox."
      else
        begin
          client.destroy("GroupResources/#{@resource.file_name}")
          flash[:success] = "Resource Deleted"
        rescue Dropbox::API::Error::NotFound
          flash[:success] = "Resource Deleted"
        rescue Dropbox::API::Error => e
          flash[:warning] = "Resource Deleted, but could not delete the file from Dropbox: #{e.message}."
        end
      end
    else
      flash[:danger] = "Could not delete Resource"
    end
    redirect_to resources_group_path(@group)
  end

  private

  def resource_params
    params.require(:group_resource).permit(:name, :description, :category)
  end

  def group_params
    params.require(:group).permit(:name, :creator, :limited, :description)
  end

  def valid_dropbox
    @group = Group.find_by(id: params[:id])

    unless !(current_user.dropbox_token.blank? or current_user.dropbox_secret.blank? or (client = Dropbox::API::Client.new(token: current_user.dropbox_token, secret: current_user.dropbox_secret)).nil?)
      flash[:warning] = "You must connect your account to Dropbox to upload files."
      redirect_to resources_group_path(@group)
    end
  end

  def valid_resource
    @group = Group.find_by(id: params[:id])
    @resource = GroupResource.find_by(id: params[:resource_id])
    if @resource.nil? or @resource.group != @group
      flash[:danger] = "No such resource exists with an id #{params[:resource_id]}"
      redirect_to resources_group_path(@group)
    end
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

  def update_last_visited
    gm = GroupMembership.find_by(group_id: params[:id], user_id: current_user.id)
    unless gm.nil?
      gm.touch :last_visited_at
    end
  end

  def can_edit_resource
    @group = Group.find_by(id: params[:id])
    @resource = CourseResource.find_by(id: params[:resource_id])
    unless (!@resource.user.nil? and current_user?(@resource.user)) or current_user.adminOfGroup?(@group) or current_user.admin?
      flash[:danger] = "You do not have the permission to do that."
      redirect_to resources_group_path(@group)
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
