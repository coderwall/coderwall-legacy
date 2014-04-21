# encoding: utf-8

#coderwall flavored markdown
module CFM
  class Markdown
    class << self
      def render(text)
        renderer = Redcarpet::Render::HTML.new
        extensions = {fenced_code_blocks: true, strikethrough: true, autolink: true}
        redcarpet = Redcarpet::Markdown.new(renderer, extensions)
        redcarpet.render(render_cfm(text)) unless text.nil?
      end

      def render_cfm(text)
        #hotlink coderwall usernames to their profile
        text.gsub(/((?<!\s{4}).*)@([a-zA-Z_\-0-9]+)/) { $1+coderwall_user_link($2) }
      end

      USERNAME_BLACKLIST = %w(include)

      private
      def coderwall_user_link(username)
        (User.where(username: username).exists? && !USERNAME_BLACKLIST.include?(username)) ? ActionController::Base.helpers.link_to("@#{username}", "/#{username}") : "@#{username}"
      end
    end
  end
end