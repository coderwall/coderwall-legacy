require 'digest/md5'

class ProtipLink < ActiveRecord::Base
  belongs_to :protip
  before_save :determine_link_kind

  IMAGE_URL = /(?:([^:\/?\#]+):)?(?:\/\/([^\/?\#]*))?([^?\#]*\.(?:(jpe?g|gif|png|bmp|tiff)))(?:\?([^\#]*))?(?:\#(.*))?$/i

  IMAGE_KINDS = [:jpg, :jpeg, :gif, :png, :bmp, :tiff]

  class << self
    def generate_identifier(url)
      Digest::MD5.hexdigest(url)
    end

    def find_by_encoded_url(url)
      link = ProtipLink.find_by_identifier(ProtipLink.generate_identifier(url))
      (link and link.url == url) ? link : nil
    end

    def is_image?(link)
      match = link.match(IMAGE_URL)
      match && (IMAGE_KINDS.include? match[4].downcase.to_sym)
    end
  end

  def determine_link_kind
    match     = self.url.match(IMAGE_URL)
    self.kind = match.nil? ? :webpage : match[4].downcase
  end
end

# == Schema Information
# Schema version: 20140728205954
#
# Table name: protip_links
#
#  id         :integer          not null, primary key
#  identifier :string(255)
#  url        :string(255)
#  protip_id  :integer
#  created_at :datetime
#  updated_at :datetime
#  kind       :string(255)
#
