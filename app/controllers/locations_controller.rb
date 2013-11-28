class LocationsController < ApplicationController

  def index
    @search_string = params[:search_string]
    @order_attribute = params[:order_attribute] ? params[:order_attribute] : 'name'
    @order_direction = params[:order_direction] ? params[:order_direction] : 'ASC'

    locations = Location.complex_search(:what => @search_string,
                                    :where => [:name],
                                    :order_by => @order_attribute,
                                    :order_dir => @order_direction)

    @locations = locations.paginate(:page => params[:page], :per_page => session[:per_page])

    flash[:notice] = locations.size.to_s + " locations found."

    respond_to do |format|
      format.html
      format.xml { render :xml => locations.to_xml }
      format.json { render :json => locations.to_json }
    end
  end

  def list
    params[:order_attribute] ||= 'name'
    params[:order_direction] ||= 'ASC'
    # unpack ids
    @ids = params[:ids].split("|")

    if @ids
      @locations = Location.find(@ids, :order => params[:order_attribute] + " " + params[:order_direction]).paginate(:page => params[:page], :per_page => session[:per_page])

      flash[:notice] = @locations.size.to_s + " locations found."
    else
      flash[:errors] = 'Need an array of ids.'
    end

    # pack ids
    @ids = @ids.join("|")

    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml { render :xml => @locations.to_xml }
      format.json { render :json => @locations.to_json }
    end
  end

  def edit
    @location = Location.find(params[:id])

    respond_to do |format|
      format.html
      format.xml { render :xml => location.to_xml }
      format.json { render :json => location.to_json }
    end
  end

  def destroy
    Location.destroy(params[:id])

    respond_to do |format|
      format.html { redirect_to :action => 'index' }
      format.xml { render :xml => :ok }
      format.json { render :json => :ok }
    end
  end

  def update

    if Location.find(params[:id]).update_attributes(params[:location])
      flash[:notice] = "Location sucessfully updated."

      respond_to do |format|
        format.html { redirect_to :action => 'index' }
        format.xml { render :xml => :ok }
        format.json { render :json => :ok }
      end
    else
      flash[:errors] = "Error while updating location."

      respond_to do |format|
        format.html { redirect_to :action => 'edit', :id => params[:id] }
        format.xml { render :xml => :error }
        format.json { render :json => :error }
      end
    end
  end

end
