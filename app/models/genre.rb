# == Schema Information
# Schema version: 20100716124925
#
# Table name: genres
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  desc       :text
#  created_at :datetime
#  updated_at :datetime
#

class Genre < ActiveRecord::Base
  has_many :bands
end
