# == Schema Information
# Schema version: 20100716124925
#
# Table name: instruments
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Instrument < ActiveRecord::Base
  has_many :performers
  has_many :artists, -> { uniq }, :through => :performers

  has_many :performances, :through => :performers


  before_update :check_for_merge

  validates_presence_of :name, :message => "must have a name"

  #relation utility
  # code stink
  def events
    #we reject the empty event, i.e. where event.name == ""
    self.performances.map{ |p| p.event }.uniq.reject{ |e| e.name == "" }
  end



  #get array of Instrument given a comma separared list
  def self.get_instruments(string)
    instruments = []
    instruments_split = string.split(',')

    instruments_split.each do |name|
      instruments << self.get_instance(:name => name.strip)
    end

    return instruments
  end


  #TODO: refactor destroy and valid_destroy?
  def destroy
    super if valid_destroy?
  end

  def valid_destroy?
    occurrences = Performer.count(:conditions => ["instrument_id = ?", id])
    if occurrences == 0
      true
    else
      false
    end
  end

### private ###
  private

  #TODO: refactor with equivalent method in Artist ?  (low priority)
  def check_for_merge
    if duplicate_instance = get_duplicate_instance
      merge_instruments_in_performers_for(duplicate_instance.id)
      duplicate_instance.destroy unless duplicate_instance.destroyed?
    end
  end

  def merge_instruments_in_performers_for(id_to_be_changed)
    list_of_performers_for_update = Performer.find(:all, :conditions => {:instrument_id => id_to_be_changed})

    list_of_performers_for_update.each do |performer|
      # we check to see if update will cause a same performer combination(artist and instrument)
      # to appear in one single performance

      if performer_is_duplicated_in_its_performance?(performer, id)
        performer.destroy
        logger.debug "destroyed #{performer.errors.size}"
      else
        performer.update_attributes(:instrument_id => id)
      end
    end
  end

  def get_duplicate_instance
    Instrument.find(:first, :conditions => { :name => name })
  end

  def performer_is_duplicated_in_its_performance?(performer, id)
    list_of_performers = Performer.find(:first, :conditions => {:instrument_id => id,
                                                              :artist_id => performer.artist_id,
                                                              :performance_id => performer.performance_id })
    !list_of_performers.nil?
  end


end
