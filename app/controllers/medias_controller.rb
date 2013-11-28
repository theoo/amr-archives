class MediasController < ApplicationController

  def index
    @search_string = params[:search_string]
    @order_attribute = params[:order_attribute]
    @order_direction = params[:order_direction]

    medias = Media.complex_search(:what => @search_string,
                                    :where => [:name, :url],
                                    :order_by => @order_attribute,
                                    :order_dir => @order_direction)

    @medias = medias.paginate(:page => params[:page], :per_page => session[:per_page])

    flash[:notice] = medias.size.to_s + " medias found."

    respond_to do |format|
      format.html
      format.xml { render :xml => medias.to_xml }
      format.json { render :json => medias.to_json }
    end
  end

  def list
    params[:order_attribute] ||= 'name'
    params[:order_direction] ||= 'ASC'
    # unpack ids
    @ids = params[:ids].split("|")

    if @ids
      @medias = Media.find(@ids, :order => params[:order_attribute] + " " + params[:order_direction]).paginate(:page => params[:page], :per_page => session[:per_page])

      flash[:notice] = @medias.size.to_s + " medias found."
    else
      flash[:errors] = 'Need an array of ids.'
    end

    # pack ids
    @ids = @ids.join("|")

    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml { render :xml => @medias.to_xml }
      format.json { render :json => @medias.to_json }
    end
  end

  def edit
    @media = Media.find(params[:id])

    respond_to do |format|
      format.html
      format.xml { render :xml => media.to_xml }
      format.json { render :json => media.to_json }
    end
  end

  def search
    @search_string = params[:search_string]
    search_string = "(" + params[:search_string].split(" ").join(')|(') + ")"

    medias = Media.find(:all,
                          :conditions => "name REGEXP '#{search_string}'")
    @medias = medias.paginate(:page => params[:page], :per_page => session[:per_page])

    flash[:notice] = medias.size.to_s + " medias found."

    respond_to do |format|
      format.html { render :action => 'index' }
      format.xml { render :xml => medias.to_xml }
      format.json { render :json => medias.to_json }
    end

  end

  def destroy
    Media.destroy(params[:id])

    respond_to do |format|
      format.html { redirect_to :action => 'index' }
      format.xml { render :xml => :ok }
      format.json { render :json => :ok }
    end
  end

  def update

    if Media.find(params[:id]).update_attributes(params[:media])
      flash[:notice] = "Media sucessfully updated."

      respond_to do |format|
        format.html { redirect_to :action => 'index' }
        format.xml { render :xml => :ok }
        format.json { render :json => :ok }
      end
    else
      flash[:errors] = "Error while updating media."

      respond_to do |format|
        format.html { redirect_to :action => 'edit', :id => params[:id] }
        format.xml { render :xml => :error }
        format.json { render :json => :error }
      end
    end
  end

end
