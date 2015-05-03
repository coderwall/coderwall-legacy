module UserWtf
  extend ActiveSupport::Concern
  included do
    before_validation :correct_ids
    before_validation :correct_urls

    def correct_ids
      [:stackoverflow, :slideshare].each do |social_id|
        if self.try(social_id) =~ /^https?:.*\/([\w_\-]+)\/([\w\-]+|newsfeed)?/
          self.send("#{social_id}=", $1)
        end
      end
    end

    def correct_urls
      self.favorite_websites = self.favorite_websites.split(",").collect do |website|
        correct_url(website.strip)
      end.join(",") unless self.favorite_websites.nil?
    end
  end
end