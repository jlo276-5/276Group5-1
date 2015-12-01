class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :correct_user, only: [:show, :edit, :update, :destroy]

  # GET /events.json
  def index
    @events = current_user.events
    @schedule = []
    @exams = []
    current_user.course_memberships.each do |cm|
      cm.sections.each do |s|
        s.section_times.each do |st|
          @schedule << st
        end
        s.exams.each do |e|
          @exams << e
        end
      end
    end
    respond_to do |format|
      format.json
      format.all { redirect_to home_path }
    end
  end

  def user_events
    @user = User.find_by(id:params[:user_id])
    if @user and @user.privacy_setting and (current_user?(@user) or @user.privacy_setting.display_schedule)
      @events = @user.events
      @schedule = []
      @exams = []
      @user.course_memberships.each do |cm|
        cm.sections.each do |s|
          s.section_times.each do |st|
            @schedule << st
          end
          s.exams.each do |e|
            @exams << e
          end
        end
      end
    else
      @events = []
      @schedule = []
      @exams = []
    end
    render :index
  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)
    @event.user = current_user
    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def correct_user
      unless current_user?(@event.user) or current_user.more_powerful(true, @event.user)
        params[:danger] = "You do not have the permission to do that."
        redirect_to home_path
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find_by(id: params[:id])
      unless @event
        params[:danger] = "No Event with ID #{params[:id]}"
        redirect_to home_path
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params[:event][:dow] ||= []
      params.require(:event).permit(:title, :description, :start_time, :end_time, :start_date, :end_date, dow: [])
    end
end
