# == Schema Information
# Schema version: 20100716124925
#
# Table name: performances
#
#  id          :integer(4)      not null, primary key
#  event_id    :integer(4)
#  location_id :integer(4)
#  band_id     :integer(4)
#  date        :date
#  desc        :text
#  created_at  :datetime
#  updated_at  :datetime
#

require 'set'

class Performance < ActiveRecord::Base
  belongs_to :band, :dependent => :destroy
  belongs_to :location, :dependent => :destroy
  belongs_to :event, :dependent => :destroy

  has_many :performers, :dependent => :destroy
  has_many :medias, :dependent => :destroy

  has_many :artists, :through => :performers
  has_many :instruments, :through => :performers

  validates_associated :band, :location, :event


  #TODO: improve validation of date
  validates_format_of :date, :with => /\d{4}-\d{1,2}-\d{1,2}/, :message => "Date must be in the following format: dd.mm.yyyy"

  def date_formatted
   date.strftime '%d.%m.%Y'
  end

  #list of uniq performers
  def artists
    # FIXME: improve perfs (SQL)
    artists = self.performers.map{ |p| p.artist }.uniq
    artists.sort! { |a, b| a.last_name.downcase <=> b.last_name.downcase }
  end

  #list of instruments for unique artist at this performance
  def instruments_for_artist a
    performers = self.performers.all(:conditions => {:artist_id => a.id} )
    instruments = performers.map { |p| p.instrument }
    instruments.delete(nil)
    instruments.sort! { |a, b| a.name.downcase <=> b.name.downcase }
  end

  def list_of_instrument_names_for(artist)
    instruments = instruments_for_artist(artist)
    list_of_instrument_names = instruments.map { |i| i.name }
  end


  def array_of_even_performers
    return [] if performers.empty?

    sorted_performers = performers.sort_by(&:last_name)
    count = 0
    array = []
    artist = sorted_performers.first.artist
    sorted_performers.each do |p|
      if p.artist.id != artist.id
        count += 1
        artist = p.artist
      end
      array << count
    end

    array
  end


end
