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

      USERNAME_BLACKLIST = %w(include)

      private

      def render_cfm(text)
        text.lines.map do |x|
          inspect_line(x)
        end.join('')
      end

      def coderwall_user_link(username)
        (User.where(username: username).exists? && !USERNAME_BLACKLIST.include?(username)) ? ActionController::Base.helpers.link_to("@#{username}", "/#{username}") : "@#{username}"
      end

      def inspect_line(line)
        #hotlink coderwall usernames to their profile, but don't search for @mentions in code blocks
        if line.start_with?('    ')
          line
        else
          line.gsub(/((?<!\s{4}).*)@([a-zA-Z_\-0-9]+)/) { $1+coderwall_user_link($2) }
        end
      end
    end
  end
end
