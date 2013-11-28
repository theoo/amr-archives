# == Schema Information
# Schema version: 20100716124925
#
# Table name: locations
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  desc       :text
#  created_at :datetime
#  updated_at :datetime
#



class Location < ActiveRecord::Base
  has_many :performances
  has_many :events, -> { uniq }, :through => :performances

  validates_presence_of :name, :message => "must have a name"

  before_update :check_for_merge

  def destroy
    super if valid_destroy?
  end


  def valid_destroy?
    occurrences = Performance.count(:conditions => ["location_id = ?", id])
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
      update_locations_in_performances_for(duplicate_instance.id)
      duplicate_instance.destroy
    end
  end

  def update_locations_in_performances_for(id_to_be_changed)
    list_of_performances_for_update = Performance.find(:all, :conditions => {:location_id => id_to_be_changed})

    list_of_performances_for_update.each do |performance|
      performance.update_attributes(:location_id => id)
    end
  end

  def get_duplicate_instance
    Location.find(:first, :conditions => { :name => name })
  end

end
