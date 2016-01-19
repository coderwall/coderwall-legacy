# encoding: utf-8

#coderwall flavored markdown
module CFM
  class Markdown
    class << self
      def render(text)
        return nil if text.nil?

        extensions = {
          fenced_code_blocks: true,
          strikethrough: true,
          autolink: true
        }

        renderer  = Redcarpet::Render::HTML.new(  link_attributes: {rel: "nofollow"})
        redcarpet = Redcarpet::Markdown.new(renderer, extensions)
        html      = redcarpet.render(render_cfm(text))
        html      = add_nofollow(html)
        html
      end

      USERNAME_BLACKLIST = %w(include)

      private

      def add_nofollow( html)
        #redcarpet isn't adding nofollow like it is suppose to.
       html.scan(/(\<a href=["'].*?["']\>.*?\<\/a\>)/).flatten.each do |link|
         if link.match(/\<a href=["'](http:\/\/|www){0,1}((coderwall.com)(\/.*?){0,1}|\/.*?)["']\>(.*?)\<\/a\>/)
          else
          link.match(/(\<a href=["'](.*?)["']\>(.*?)\<\/a\>)/)
          html.gsub!(link, "<a href='#{$2}' rel='nofollow' >#{$3}</a>" )
          end
        end
        html
      end

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
