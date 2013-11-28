# == Schema Information
# Schema version: 20100716124925
#
# Table name: performers
#
#  id             :integer(4)      not null, primary key
#  artist_id      :integer(4)
#  instrument_id  :integer(4)
#  performance_id :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#

class Performer < ActiveRecord::Base
  belongs_to :artist, :dependent => :destroy
  belongs_to :instrument, :dependent => :destroy
  belongs_to :performance

  validate :duplicate_performer_in_one_performance


  def duplicate_performer_in_one_performance

    unless performance_id.nil? # allow creation via csv import
      if Performer.find(:first, :conditions => {:performance_id => performance_id,
                                                :artist_id => artist_id,
                                                :instrument_id => instrument_id })
        errors.add(:performance_id, "can't have duplicate performers'")
      end
    end
  end



#  # You can write it in a funyer way if you want.
#  %w{full_name first_name middle_name last_name}.each do |method|
#    define_method(method) { self.artist.send(method) }
#  end


  def full_name
    self.artist.full_name
  end

  def first_name
    self.artist.first_name
  end

  def middle_name
    self.artist.middle_name
  end

  def last_name
    self.artist.last_name
  end




end
