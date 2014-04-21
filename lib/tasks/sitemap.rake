namespace :sitemap do
  task :generate => :environment do
    xml = "<urlset xmlns='http://www.sitemaps.org/schemas/sitemap/0.9'>"
    User.active.find_each(:batch_size => 1000) do |user|
      xml << "<url>"
      xml << "  <loc>http://coderwall.com/#{user.username}</loc>"
      xml << "  <lastmod>#{user.updated_at.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")}</lastmod>"
      xml << "  <changefreq>weekly</changefreq>"
      xml << "  <priority>0.5</priority>"
      xml << "</url>"
    end
    %w{achievements faq contact_us privacy_policy tos}.each do |page|
      xml << "<url>"
      xml << "  <loc>http://coderwall.com/#{page}</loc>"
      xml << "  <lastmod>#{Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")}</lastmod>"
      xml << "  <changefreq>monthly</changefreq>"
      xml << "  <priority>0.5</priority>"
      xml << "</url>"
    end
    xml << "</urlset>"
    sitemap = File.join(Rails.root, 'app', 'views', 'pages', 'sitemap.xml')
    File.open(sitemap, 'w') { |f| f.write(xml) }
    puts "DONE: #{sitemap}"
  end

  task :ping => :environment do
    require 'open-uri'
    require 'timeout'

    sitemap_index_url = 'http://coderwall.com/sm.xml'
    search_engines = {
        :google => "http://www.google.com/webmasters/sitemaps/ping?sitemap=#{sitemap_index_url}",
        :ask => "http://submissions.ask.com/ping?sitemap=#{sitemap_index_url}",
        :bing => "http://www.bing.com/webmaster/ping.aspx?siteMap=#{sitemap_index_url}",
        :sitemap_writer => "http://www.sitemapwriter.com/notify.php?crawler=all&url=#{sitemap_index_url}"
    }

    search_engines.each do |engine, link|
      begin
        Timeout::timeout(10) {
          open(link)
        }
        puts "Successful ping of #{engine.to_s.titleize}" if verbose
      rescue Timeout::Error, StandardError => e
        puts "Ping failed for #{engine.to_s.titleize}: #{e.inspect} (URL #{link})" if verbose
      end
    end
  end
end