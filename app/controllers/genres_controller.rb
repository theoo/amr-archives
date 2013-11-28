class GenresController < ApplicationController

  def index
    @search_string = params[:search_string]
    @order_attribute = params[:order_attribute]
    @order_direction = params[:order_direction]

    genres = Genre.complex_search(:what => @search_string,
                                    :where => [:name],
                                    :order_by => @order_attribute,
                                    :order_dir => @order_direction)

    @genres = genres.paginate(:page => params[:page], :per_page => session[:per_page])

    flash[:notice] = genres.size.to_s + " genres found."

    respond_to do |format|
      format.html
      format.xml { render :xml => genres.to_xml }
      format.json { render :json => genres.to_json }
    end
  end

  def list
    params[:order_attribute] ||= 'name'
    params[:order_direction] ||= 'ASC'
    # unpack ids
    @ids = params[:ids].split("|")

    if @ids
      @genres = Genre.find(@ids, :order => params[:order_attribute] + " " + params[:order_direction]).paginate(:page => params[:page], :per_page => session[:per_page])

      flash[:notice] = @genres.size.to_s + " genres found."
    else
      flash[:errors] = 'Need an array of ids.'
    end

    # pack ids
    @ids = @ids.join("|")

    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml { render :xml => @genres.to_xml }
      format.json { render :json => @genres.to_json }
    end
  end

  def edit
    @genre = Genre.find(params[:id])

    respond_to do |format|
      format.html
      format.xml { render :xml => genre.to_xml }
      format.json { render :json => genre.to_json }
    end
  end

  def destroy
    Genre.destroy(params[:id])

    respond_to do |format|
      format.html { redirect_to :action => 'index' }
      format.xml { render :xml => :ok }
      format.json { render :json => :ok }
    end
  end

  def update

    if Genre.find(params[:id]).update_attributes(params[:genre])
      flash[:notice] = "Genre sucessfully updated."

      respond_to do |format|
        format.html { redirect_to :action => 'index' }
        format.xml { render :xml => :ok }
        format.json { render :json => :ok }
      end
    else
      flash[:errors] = "Error while updating genre."

      respond_to do |format|
        format.html { redirect_to :action => 'edit', :id => params[:id] }
        format.xml { render :xml => :error }
        format.json { render :json => :error }
      end
    end
  end

end
