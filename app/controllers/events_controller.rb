class EventsController < ApplicationController

  before_filter :report_dates, :only => [:index]

  def index
    @events = Event.where('starttime >= ? AND endtime <= ?', @start_date, @end_date )
  end

  def show
    @event = Event.find(params[:id])
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(params[:event])
    if @event.save
      redirect_to @event, :notice => "Successfully created event."
    else
      render :action => 'new'
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    if @event.update_attributes(params[:event])
      redirect_to @event, :notice  => "Successfully updated event."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    redirect_to events_url, :notice => "Successfully destroyed event."
  end

  def import
    Event.import(params[:file])
    redirect_to events_url, notice: "Events imported.", :errors => @errors.to_json
  end
end

private

def report_dates
    if params[:start_date].present?
        @start_date = params[:start_date]
        @end_date = params[:end_date]
        cookies[:start_date] = { :value => @start_date, :expires => 1.hour.from_now }
        cookies[:end_date] = { :value => @end_date, :expires => 1.hour.from_now }
    elsif cookies[:start_date].present? and cookies[:end_date].present?
        @start_date = cookies[:start_date]
        @end_date = cookies[:end_date]
    else
        @start_date = Date.today
        @end_date = Date.today
    end

    @start_date = @start_date.to_datetime.beginning_of_day
    @end_date = @end_date.to_datetime.end_of_day

    if @start_date > @end_date
        @start_date = @end_date
    end
end
