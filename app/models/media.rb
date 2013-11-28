# == Schema Information
# Schema version: 20100716124925
#
# Table name: medias
#
#  id             :integer(4)      not null, primary key
#  performance_id :integer(4)
#  name           :string(255)
#  mime           :string(255)
#  url            :text
#  created_at     :datetime
#  updated_at     :datetime
#

class Media < ActiveRecord::Base

  self.table_name = 'medias'

  belongs_to :performance

  validates_presence_of :name, :message => "must have a name"

  # validate :validate_uri

  before_save :check_for_nil
  before_destroy :remove_file

  def public_url
    if self.url.match("^public(.*)")
      "http://" + HOSTNAME + self.url.match("^public(.*)")[1]
    else
      self.url
    end
  end

  private

  def remove_file
    if File.exist?(self.url)
      FileUtils.rm( self.url )
    end
  end

  # orginally copy pasted from => http://actsasblog.wordpress.com/2006/10/16/url-validation-in-rubyrails/
  def validate_uri
    begin
      uri = URI.parse(url)
      if uri.class != URI::HTTP
        errors.add(:url, 'Only HTTP protocol addresses can be used')
      end
    rescue URI::InvalidURIError
        errors.add(:url, "The format of the url is not valid.")
    end
  end

  def check_for_nil
    self.mime ||= ""
  end


end
