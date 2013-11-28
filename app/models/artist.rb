# == Schema Information
# Schema version: 20100716124925
#
# Table name: artists
#
#  id          :integer(4)      not null, primary key
#  first_name  :string(255)
#  middle_name :string(255)
#  last_name   :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Artist < ActiveRecord::Base
  has_many :performers
  has_many :instruments, -> { uniq }, :through => :performers
  has_many :performances, -> { uniq }, :through => :performers
  has_many :bands, :through => :performances

  validates_presence_of :last_name, :message => "must contain at least a last name"

  before_save :check_fields_for_nil

  before_update :check_for_merge

### attributes ###
  def full_name
    first_name = self.first_name.empty? ? "" : "#{self.first_name} "
    middle_name = self.middle_name.empty? ? "" : "#{self.middle_name} "
    "" << first_name << middle_name << last_name
  end

  def full_name_reverse
    "#{self.last_name} #{self.middle_name} #{self.first_name}".strip
  end

  def self.get_instance(params={})

      return nil if params.empty?

      #TODO: messy refactor
      if params.has_key?(:full_name)

        split_names = params[:full_name].split

        if split_names.length == 1
          first_name, middle_name = "", ""
        else
          first_name = split_names.first.to_s
        end

        if split_names.empty?
          middle_name = ""
        else
          middle_name = split_names[1..-2].join(" ")
        end

        last_name = split_names.last.to_s

      elsif params.has_key?(:last_name) &&  ! params[:last_name].to_s.empty?
        first_name, middle_name, last_name = params[:first_name].to_s, params[:middle_name].to_s, params[:last_name].to_s
      else
        return nil
      end


      artist = _get_instance(:first_name => first_name,
                             :middle_name => middle_name,
                             :last_name => last_name)
      return artist
  end

  def destroy
    super if valid_destroy?
  end

  def valid_destroy?
    occurrences = Performer.count(:conditions => ["artist_id = ?", id])
    if occurrences == 0
      true
    else
      false
    end
  end

### relationships ###
  def bands
    Band.find(self.performances.map{|p| p.band_id}.uniq)
  end

  def get_instruments_where_i_play_in_band(band)
    instrument_collection = []

    band.performances.each do |performance|
      list_of_performers = performance.performers.select { |performer| performer.artist == self }
      list_of_performers.each { |p| instrument_collection << p.instrument }
    end

    instrument_collection
  end

  def get_performances_where_i_play(instrument)
    self.performances.select { |p| p.instruments.include?(instrument) }
  end

  def get_performances_where_i_play_in_band(band)
    self.performances.select { |p| p.band == band }
  end

### private ###

  private

  def self._get_instance( arguments_hash )
    if instance = self.find(:first, :conditions => arguments_hash)
    else
      instance = self.create(arguments_hash)
    end

    instance
  end

  def check_fields_for_nil
    self.first_name ||= ""
    self.middle_name ||= ""
  end

  def check_for_merge
    if duplicate_instance = get_duplicate_instance
      merge_artists_in_performers_for(duplicate_instance.id)
      duplicate_instance.destroy unless duplicate_instance.destroyed?
    end
  end

  def merge_artists_in_performers_for(id_to_be_changed)
    list_of_performers_for_update = Performer.find(:all, :conditions => {:artist_id => id_to_be_changed})

    list_of_performers_for_update.each do |performer|
      # we check to see if update will cause a same performer combination(artist and instrument)
      # to appear in one single performance

      if performer_is_duplicated_in_its_performance?(performer, id)
        performer.destroy
      else
        performer.update_attributes(:artist_id => id)
      end
    end
  end

  def get_duplicate_instance
    Artist.find(:first, :conditions => { :first_name => first_name,
                                          :middle_name => middle_name,
                                          :last_name => last_name})
  end

  def performer_is_duplicated_in_its_performance?(performer, id)
    list_of_performers = Performer.find(:first, :conditions => {:artist_id => id,
                                                              :instrument_id => performer.instrument_id,
                                                              :performance_id => performer.performance_id })
    !list_of_performers.nil?
  end

end
