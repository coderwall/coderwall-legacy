module Importers
  module Protips
    class SlideshareImporter
      class << self
        def import_from_fact(fact)
          #slideshare_display_url = "http://www.slideshare.net/slideshow/embed_code/#{fact.identity}"
          #unless Protip.already_created_a_protip_for(slideshare_display_url)
          #  user = User.where(:slideshare => fact.owner.match(/slideshare:(.+)/)[1]).first
          #  return if user.nil?
          #  Rails.logger.debug "creating slideshare: #{fact.url} by #{fact.owner}/#{user.username unless user.nil?}"
          #  user.protips.create(title: fact.name, body: slideshare_display_url, created_at: fact.relevant_on, topics: ["Slideshare"], created_by: Protip::IMPORTER, user: user)
          #end
        end
      end
    end

    class GithubImporter
      class << self
        def import_from_follows(description, link, date, owner)
          #if protiplink = ProtipLink.find_by_encoded_url(link)
          #  protiplink.protip.upvote_by(owner, owner.tracking_code, Protip::DEFAULT_IP_ADDRESS) unless protiplink.protip.nil?
          #else
          #  #Rails.logger.debug "creating protip:#{description}, #{link}"
          #  #language = Github.new.predominant_repo_lanugage_for_link(link)
          #  #description = (description && description.slice(0, Protip::MAX_TITLE_LENGTH))
          #  #owner.protips.create(title: description, body: link, created_at: date, topics: ["Github", language].compact, created_by: Protip::IMPORTER, user: owner)
          #end
        end
      end
    end
  end
end
