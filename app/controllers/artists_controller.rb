class ArtistsController < ApplicationController

  def index
    @search_string = params[:search_string]
    @order_attribute = params[:order_attribute] ? params[:order_attribute] : 'last_name'
    @order_direction = params[:order_direction] ? params[:order_direction] : 'ASC'

    artists = Artist.complex_search(:what => @search_string,
                                    :where => [:first_name, :last_name],
                                    :order_by => @order_attribute,
                                    :order_dir => @order_direction)

    @artists = artists.paginate(:page => params[:page], :per_page => session[:per_page])

    flash[:notice] = artists.size.to_s + " artists found."

    respond_to do |format|
      format.html
      format.xml { render :xml => artists.to_xml }
      format.json { render :json => artists.to_json }
    end
  end

  def list
    params[:order_attribute] ||= 'first_name'
    params[:order_direction] ||= 'ASC'
    # unpack ids
    @ids = params[:ids].split("|")

    if @ids
      @artists = Artist.where(id: @ids)
        .order(params[:order_attribute] + " " + params[:order_direction])
        .paginate(:page => params[:page], :per_page => session[:per_page])

      flash[:notice] = @artists.size.to_s + " artists found."
    else
      flash[:errors] = 'Need an array of ids.'
    end

    # pack ids
    @ids = @ids.join("|")

    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml { render :xml => @artists.to_xml }
      format.json { render :json => @artists.to_json }
    end
  end

  def show
    @artist = Artist.find(params[:id])
  end

  def edit
    @artist = Artist.find(params[:id])

    respond_to do |format|
      format.html
      format.xml { render :xml => artist.to_xml }
      format.json { render :json => artist.to_json }
    end
  end

  def destroy
    Artist.destroy(params[:id])

    respond_to do |format|
      format.html { redirect_to :action => 'index' }
      format.xml { render :xml => :ok }
      format.json { render :json => :ok }
    end
  end

  def update

    if Artist.find(params[:id]).update_attributes(params[:artist])
      flash[:notice] = "Artist sucessfully updated."

      respond_to do |format|
        format.html { redirect_to :action => 'index' }
        format.xml { render :xml => :ok }
        format.json { render :json => :ok }
      end
    else
      flash[:errors] = "Error while updating artist."

      respond_to do |format|
        format.html { redirect_to :action => 'edit', :id => params[:id] }
        format.xml { render :xml => :error }
        format.json { render :json => :error }
      end
    end
  end
end
