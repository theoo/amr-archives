class InstrumentsController < ApplicationController

  def index
    @search_string = params[:search_string]
    @order_attribute = params[:order_attribute] ? params[:order_attribute] : 'name'
    @order_direction = params[:order_direction] ? params[:order_direction] : 'ASC'

    instruments = Instrument.complex_search(:what => @search_string,
                                    :where => [:name],
                                    :order_by => @order_attribute,
                                    :order_dir => @order_direction)

    @instruments = instruments.paginate(:page => params[:page], :per_page => session[:per_page])

    flash[:notice] = instruments.size.to_s + " instruments found."

    respond_to do |format|
      format.html
      format.xml { render :xml => instruments.to_xml }
      format.json { render :json => instruments.to_json }
    end
  end

  def list
    params[:order_attribute] ||= 'name'
    params[:order_direction] ||= 'ASC'
    # unpack ids
    @ids = params[:ids].split("|")

    if @ids
      @instruments = Instrument.find(@ids, :order => params[:order_attribute] + " " + params[:order_direction]).paginate(:page => params[:page], :per_page => session[:per_page])

      flash[:notice] = @instruments.size.to_s + " instruments found."
    else
      flash[:errors] = 'Need an array of ids.'
    end

    # pack ids
    @ids = @ids.join("|")

    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml { render :xml => @instruments.to_xml }
      format.json { render :json => @instruments.to_json }
    end
  end

  def edit
    @instrument = Instrument.find(params[:id])

    respond_to do |format|
      format.html
      format.xml { render :xml => instrument.to_xml }
      format.json { render :json => instrument.to_json }
    end
  end


  def destroy
    Instrument.destroy(params[:id])

    respond_to do |format|
      format.html { redirect_to :action => 'index' }
      format.xml { render :xml => :ok }
      format.json { render :json => :ok }
    end
  end

  def update

    if Instrument.find(params[:id]).update_attributes(params[:instrument])
      flash[:notice] = "Instrument sucessfully updated."

      respond_to do |format|
        format.html { redirect_to :action => 'index' }
        format.xml { render :xml => :ok }
        format.json { render :json => :ok }
      end
    else
      flash[:errors] = "Error while updating instrument."

      respond_to do |format|
        format.html { redirect_to :action => 'edit', :id => params[:id] }
        format.xml { render :xml => :error }
        format.json { render :json => :error }
      end
    end
  end

end
