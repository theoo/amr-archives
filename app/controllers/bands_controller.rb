class BandsController < ApplicationController

  def index
    @search_string = params[:search_string]
    @order_attribute = params[:order_attribute] ? params[:order_attribute] : 'name'
    @order_direction = params[:order_direction] ? params[:order_direction] : 'ASC'

    bands = Band.complex_search(:what => @search_string,
                                    :where => [:name, :desc],
                                    :order_by => @order_attribute,
                                    :order_dir => @order_direction)

    @bands = bands.paginate(:page => params[:page], :per_page => session[:per_page])

    flash[:notice] = bands.size.to_s + " bands found."

    respond_to do |format|
      format.html
      format.xml { render :xml => bands.to_xml }
      format.json { render :json => bands.to_json }
    end
  end

  def list
    params[:order_attribute] ||= 'name'
    params[:order_direction] ||= 'ASC'
    # unpack ids
    @ids = params[:ids].split("|")

    if @ids
      @bands = Band.find(@ids, :order => params[:order_attribute] + " " + params[:order_direction]).paginate(:page => params[:page], :per_page => session[:per_page])

      flash[:notice] = @bands.size.to_s + " bands found."
    else
      flash[:errors] = 'Need an array of ids.'
    end

    # pack ids
    @ids = @ids.join("|")

    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml { render :xml => @bands.to_xml }
      format.json { render :json => @bands.to_json }
    end
  end

  def show
    params[:order_direction] ||= 'ASC'
    @band = Band.find(params[:id])
  end

  def edit
    @band = Band.find(params[:id])

    respond_to do |format|
      format.html
      format.xml { render :xml => band.to_xml }
      format.json { render :json => band.to_json }
    end
  end

  def destroy
    Band.destroy(params[:id])

    respond_to do |format|
      format.html { redirect_to :action => 'index' }
      format.xml { render :xml => :ok }
      format.json { render :json => :ok }
    end
  end

  def update

    if Band.find(params[:id]).update_attributes(params[:band])
      flash[:notice] = "Band sucessfully updated."

      respond_to do |format|
        format.html { redirect_to :action => 'index' }
        format.xml { render :xml => :ok }
        format.json { render :json => :ok }
      end
    else
      flash[:errors] = "Error while updating band."

      respond_to do |format|
        format.html { redirect_to :action => 'edit', :id => params[:id] }
        format.xml { render :xml => :error }
        format.json { render :json => :error }
      end
    end
  end

end
