# encoding: utf-8
class PerformancesController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  before_filter :require_login, :only => [:create, :new, :edit, :update, :destroy]

  def index

    session[:per_page] ||= 20

    @performances = Performance.paginate(:page => params[:page], :per_page => session[:per_page])

    flash[:notice] = Performance.count.to_s + " performances found."
  end

  def list
    params[:order_attribute] ||= 'date'
    params[:order_direction] ||= 'ASC'
    # unpack ids
    @ids = params[:ids].split("|")

    if @ids
      @performances = Performance.find(@ids, :order => params[:order_attribute] + " " + params[:order_direction]).paginate(:page => params[:page], :per_page => session[:per_page])

      flash[:notice] = @performances.size.to_s + " performances found."
    else
      flash[:errors] = 'Need an array of ids.'
    end

    # pack ids
    @ids = @ids.join("|")

    respond_to do |format|
      format.html # list
      format.xml { render :xml => @performances.to_xml }
      format.json { render :json => @performances.to_json }
    end
  end


  def show
    @performance = Performance.find(params[:id])
  end

  def edit
    @performance = Performance.find(params[:id])
  end

  def new
    @performance = Performance.new
    @performance.event = Event.new
    @performance.band = Band.new
    @performance.location = Location.new
  end

  def update
    @performance = Performance.find(params[:id])
    super_hash = {}
    super_hash[:location] = Location.get_instance(:name => params[:location_name], :desc => "" )
    super_hash[:band] = Band.get_instance(:name => params[:band_name], :desc => "" )
    super_hash[:event] = Event.get_instance(:name => params[:event_name], :desc => "" )
    super_hash[:date] = params[:date]
    super_hash[:doors_opening] = params[:doors]
    super_hash[:desc] = params[:desc]
    super_hash[:ticketing] = params[:ticketing]
    super_hash[:price] = params[:price]


    if @performance.update_attributes(super_hash)
      redirect_to :action => 'index'
    else
      redirect_to :action => 'edit', :id => @performance.id
    end

  end

  def destroy
    @performance = Performance.find(params[:id])
    @performance.destroy

    flash[:notice] = "Successfully destroyed performance."

    respond_to do |format|
      format.html { redirect_to(performances_url) }
    end
  end


  def create
    @performance = Performance.new

    @performance.location = Location.get_instance(:name => params[:location_name], :desc => "")
    @performance.band = Band.get_instance(:name => params[:band_name], :desc => "")
    @performance.event = Event.get_instance(:name => params[:event_name], :desc => "")
    @performance.date = params[:date]
    @performance.desc = params[:desc]

    @performance.doors_opening = params[:doors]
    @performance.price = params[:price]
    @performance.ticketing = params[:ticketing]

    if @performance.save
      flash[:success] = "performance added"
      redirect_to :action => 'edit', :id => @performance.id
    else
      flash[:error] = @performance.errors
      render 'new'
    end
  end

############################### Ajax

################# Performer

  def add_performer
    @performance = Performance.find(params[:id])

    @artist = Artist.get_instance(params[:artist])
    @instruments = Instrument.get_instruments(params[:instrument][:list])

    if @artist.nil? | @instruments.empty?
      flash[:error] = "artist requires last name, instrument requires a name"
      respond_to do |format|
        format.js { render :template  => "performances/error.rjs" }
      end
    else
      @instruments.each do |i|
        new_performer = Performer.new(:artist => @artist, :instrument => i, :performance => @performance)
        @performance.performers << new_performer if new_performer.valid?
      end

      flash[:notice] = "new performer added"

      respond_to do |format|
        #format.html { }
        format.js    #calls add_performer.rjs
      end
    end
  end


  def delete_performer
    @id_for_removal = params[:id]
    @performer = Performer.find(@id_for_removal)
    @performer.destroy

    respond_to do |format|
      #format.html {}
      format.js    #calls delete_performer.rjs
    end
  end

################# Performer edit
  def edit_artist
    @performer_id = params[:id]
    @artist = Artist.find(Performer.find(@performer_id).artist)

    respond_to do |format|
      #format.html { }
      format.js    #calls edit_artist.rjs
    end

  end

  def update_artist

    @performer_id = params[:id]
    performer = Performer.find(@performer_id)
    @artist = Artist.find_or_create_by_first_name_and_middle_name_and_last_name(params[:artist])


    #check if no change has been made,
    if performer.artist == @artist
      reload
      return  #no change abort
    end

    performer.artist = @artist

    if performer.save
      reload
    else
      display_errors(@artist.errors)
    end
  end


  def edit_instrument
    @performer_id = params[:id]
    @instrument = Instrument.find(Performer.find(@performer_id).instrument)

    respond_to do |format|
      #format.html { }
      format.js    #calls edit_instrument.rjs
    end

  end

  def update_instrument
    @performer_id = params[:id]
    performer = Performer.find(@performer_id)
    @instrument = Instrument.get_instance(params[:instrument])


    #check if no change has been made
    if performer.instrument == @instrument
      reload
      return
    end

    performer.instrument = @instrument

    if performer.save
      reload
    else
      display_errors(@instrument.errors)
    end

  end


################# Media
  def add_media

    @performance = Performance.find(params[:id])
    if params[:media_add][:url]
      input_file = params[:media_add][:url]

      name = @performance.id.to_s + "_" + input_file.original_filename
      # name = params[:media_add][:name]
      directory = "public/data"

      path = File.join(directory, name)
      while File.exist?(path)
        name = "1-" + name
        path = File.join(directory, name)
      end

      if params[:media_add][:name] == 'featured'

        # image MUST be 685x220 [px]
        image = input_file.read
        imgs = Image.from_blob(image)

        featured = imgs.first
        featured_path = File.join(directory,"featured-" + name)
        featured.write featured_path
        mime = (`file -ib #{featured_path}`).split(";").first.strip
        @featured = @performance.medias.create( :url => featured_path,
                          :name => 'featured',
                          :mime => mime)
        @performance.medias << @featured

        # resizing the height to 121px
        geometry = Geometry.new(nil, 115)
        thumbnail = imgs.first.change_geometry!(geometry) do |cols, rows, img|
          img.resize!(cols, rows)
        end

        # center crop 205px
        thumbnail.crop!(NorthGravity, 205, 115)
        thumbnail_path = File.join(directory,"thumbnail-" + name)
        thumbnail.write thumbnail_path
        mime = (`file -ib #{thumbnail_path}`).split(";").first.strip
        @thumbnail = @performance.medias.create( :url => thumbnail_path,
                          :name => 'thumbnail',
                          :mime => mime)
        @performance.medias << @thumbnail

      else

        File.open(path, "wb") { |f| f.write(input_file.read) }

        mime = (`file -ib #{path}`).split(";").first.strip
        @media = @performance.medias.create( :url => path,
                          :name => params[:media_add][:name],
                          :mime => mime)
      end

    end

    respond_to do |format|
      format.html { redirect_to edit_performance_path(@performance) }
      format.js    #calls add_media.rjs
    end

  end

  def delete_media
    @id_for_removal = params[:id]
    media = Media.find(@id_for_removal)
    media.destroy

    respond_to do |format|
      #format.html {}
      format.js    #calls delete_media.rjs
    end
  end

  def update_media
    @media = Media.find(params[:id])

    if @media.update_attributes(params[:media])
      reload
    else
      display_errors(@media.errors)
    end
  end

  def remote_catalog

    if params[:interval]
      if params[:interval][:start]
        i_start = Time.parse(params[:interval][:start])
      end

      if params[:interval][:end]
        i_end = Time.parse(params[:interval][:end])
      end
    end

    i_start ||= Time.now
    i_end   ||= Time.now

    i_end = i_end.end_of_day

    perfs = Performance.find( :all, :order => 'date ASC',
                              :conditions => {:date => i_start..i_end},
                              :include => 'medias')


    perfss = perfs.map do |p|
      image_mime = %w(image/jpeg image/gif image/png)
      audio_mime = %w(audio/basic audio/mpeg)
      video_mime = %w(video/mpeg video/quicktime)

      featured = p.medias.find(:first,
        :conditions => {:name => 'thumbnail', :mime => image_mime})
      images = p.medias.find(:all,
        :conditions => ["name != 'featured' and name != 'thumbnail' and mime IN ('#{image_mime.join("','")}')"])
      videos = p.medias.find(:all,
        :conditions => {:mime => video_mime})
      audios = p.medias.find(:all,
        :conditions => {:mime => audio_mime})

      # location and stage HACK while there is no proper migration
      location, stage = p.location.name.split("|")

      entry = { :id => p.id,
        :url => performance_url(p),
        :date => p.date,
        :event_name => p.event.name,
        :band => p.band.name,
        :location => location,
        :doors => p.doors_opening,
        :description => p.desc,
      	:price => p.price,
      	:ticketing => p.ticketing,
        :performance_start => p.date.strftime("%Hh%M"),
        :stage => stage}

      # resize featured image by 205x121
      entry[:featured_image] = {:name => featured.name, :url => featured.public_url} if featured

      entry[:images] = images.map{|m| {:name => m.name, :url => m.public_url}} if images.size > 0
      entry[:videos] = videos.map{|m| {:name => m.name, :url => m.public_url}} if videos.size > 0
      entry[:audios] = audios.map{|m| {:name => m.name, :url => m.public_url}} unless audios.empty?

      entry[:artists] = p.artists.map do |a|
        { :name => a.full_name, :instruments => p.list_of_instrument_names_for(a).join(", ") }
      end

      entry
    end

    respond_to do |format|
      format.html { render :text => perfss.inspect }
      format.xml  { render :xml => perfss.to_xml }
      format.json do
        render :json => perfss.to_json,
               :callback => params[:callback]
      end
    end
  end

  def remote_performance
    p = Performance.find params[:id]

    image_mime = %w(image/jpeg image/gif image/png)
    audio_mime = %w(audio/basic audio/mpeg)
    video_mime = %w(video/mpeg video/quicktime)

    featured = p.medias.find(:first,
      :conditions => {:name => 'featured', :mime => image_mime})
    images = p.medias.find(:all,
      :conditions => ["name != 'featured' and name != 'thumbnail' and mime IN ('#{image_mime.join("','")}')"])
    videos = p.medias.find(:all,
      :conditions => {:mime => video_mime})
    audios = p.medias.find(:all,
      :conditions => {:mime => audio_mime})

    # location and stage HACK while there is no proper migration
    location, stage = p.location.name.split("|")
    stage = "" if stage.nil?

    entry = { :id => p.id,
      :date => p.date,
      :event_name => p.event.name,
      :description => p.desc,
      :band => p.band.name,
      :location => location.strip,
      :stage => stage.strip,
      :price => p.price,
      :ticketing => p.ticketing,
      :doors => p.doors_opening,
      :performance_start => p.date.strftime("%Hh%M") }

    # resize featured image by 685x220
    entry[:featured_image] = {:name => featured.name, :url => featured.public_url} if featured

    entry[:images] = images.map{|m| {:name => m.name, :url => m.public_url}} if images.size > 0
    entry[:videos] = videos.map{|m| {:name => m.name, :url => m.public_url}} if videos.size > 0
    entry[:audios] = audios.map{|m| {:name => m.name, :url => m.public_url}} unless audios.empty?

    entry[:artists] = p.artists.map do |a|
      {:name => a.full_name, :instruments => p.list_of_instrument_names_for(a).join(", ") }
    end

    respond_to do |format|
      format.html { render :text => entry.inspect }
      format.xml  { render :xml => entry.to_xml }
      format.json do
        render :json => entry.to_json,
                :callback => params[:callback]
      end
    end

  end


################# private

  private

  def record_not_found
    flash[:error] = "error:performance doesn't exist"
    redirect_to :action => :index
  end

  def reload
    respond_to do |format|
      format.js { render :template => 'performances/reload.rjs' }
    end
  end

  def display_errors(errors)
      error_string = ""
      errors.each{ |attr, msg| error_string += "error: #{msg}"}
      flash[:error] = error_string
      respond_to do |format|
        format.js { render :template => 'performances/error.rjs' }
      end
  end

end
