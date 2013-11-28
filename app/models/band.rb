# == Schema Information
# Schema version: 20100716124925
#
# Table name: bands
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  desc       :text
#  genre_id   :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Band < ActiveRecord::Base
  belongs_to :genre

  has_many :performances
  has_many :performers, :through => :performances

  has_many :artists, :through => :performers
  has_many :instruments, :through => :performers

  validates_presence_of :name

  before_update :check_for_merge

  def artists
    self.performers.map{ |p| p.artist }.uniq
  end

  def destroy
    super if valid_destroy?
  end

  def valid_destroy?
    occurrences = Performance.count(:conditions => ["band_id = ?", id])
    if occurrences == 0
      true
    else
      false
    end
  end


### private ###
  private

  #TODO: refactor with equivalent methods in Band, Location, Event
  def check_for_merge
    if duplicate_instance = get_duplicate_instance
      update_bands_in_performances_for(duplicate_instance.id)
      duplicate_instance.destroy
    end
  end

  def update_bands_in_performances_for(id_to_be_changed)
    list_of_performances_for_update = Performance.find(:all, :conditions => {:band_id => id_to_be_changed})

    list_of_performances_for_update.each do |performance|
      performance.update_attributes(:band_id => id)
    end
  end

  def get_duplicate_instance
    Band.find(:first, :conditions => { :name => name })
  end

end
