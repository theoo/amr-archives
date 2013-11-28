class EventsController < ApplicationController

  def index
    @search_string = params[:search_string]
    @order_attribute = params[:order_attribute] ? params[:order_attribute] : 'name'
    @order_direction = params[:order_direction] ? params[:order_direction] : 'ASC'

    events = Event.complex_search(:what => @search_string,
                                    :where => [:name],
                                    :order_by => @order_attribute,
                                    :order_dir => @order_direction)

    @events = events.paginate(:page => params[:page], :per_page => session[:per_page])

    flash[:notice] = events.size.to_s + " events found."

    respond_to do |format|
      format.html
      format.xml { render :xml => events.to_xml }
      format.json { render :json => events.to_json }
    end
  end

  def list
    params[:order_attribute] ||= 'name'
    params[:order_direction] ||= 'ASC'
    # unpack ids
    @ids = params[:ids].split("|")

    if @ids
      @events = Event.find(@ids, :order => params[:order_attribute] + " " + params[:order_direction]).paginate(:page => params[:page], :per_page => session[:per_page])

      flash[:notice] = @events.size.to_s + " events found."
    else
      flash[:errors] = 'Need an array of ids.'
    end

    # pack ids
    @ids = @ids.join("|")

    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml { render :xml => @events.to_xml }
      format.json { render :json => @events.to_json }
    end
  end

  def edit
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html
      format.xml { render :xml => event.to_xml }
      format.json { render :json => event.to_json }
    end
  end

  def show
    @event = Event.find(params[:id])

   if params[:search]
    @search = Performance.where(params[:search])
   else
    @search = Performance.where(:event_id => @event.id).order('date ASC')
   end

    @performances = @search.all.uniq.paginate(:page => params[:page], :per_page => session[:per_page])
  end

  def destroy
    Event.destroy(params[:id])

    respond_to do |format|
      format.html { redirect_to :action => 'index' }
      format.xml { render :xml => :ok }
      format.json { render :json => :ok }
    end
  end

  def update

    if Event.find(params[:id]).update_attributes(params[:event])
      flash[:notice] = "Event sucessfully updated."

      respond_to do |format|
        format.html { redirect_to :action => 'index' }
        format.xml { render :xml => :ok }
        format.json { render :json => :ok }
      end
    else
      flash[:errors] = "Error while updating event."

      respond_to do |format|
        format.html { redirect_to :action => 'edit', :id => params[:id] }
        format.xml { render :xml => :error }
        format.json { render :json => :error }
      end
    end
  end


end
