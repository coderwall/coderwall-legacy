class SitemapRefreshWorker
  include Sidekiq::Worker

  sidekiq_options queue: :index

  def perform
    # ArgumentError: Missing host to link to! Please provide the :host parameter, set default_path_options[:host], or set :only_path to true
    SitemapGenerator::Sitemap.default_host  = 'https://coderwall.com'
    SitemapGenerator::Sitemap.public_path    = 'tmp/'
    SitemapGenerator::Sitemap.sitemaps_host = "http://#{ENV['FOG_DIRECTORY']}.s3.amazonaws.com/"
    SitemapGenerator::Sitemap.sitemaps_path  = 'sitemaps/'
    SitemapGenerator::Sitemap.adapter       = SitemapGenerator::WaveAdapter.new

    SitemapGenerator::Sitemap.create do
      add('/welcome', priority: 0.7, changefreq: 'monthly')
      add('/contact_us', priority: 0.2, changefreq: 'monthly')
      add('/blog', priority: 0.5, changefreq: 'weekly')
      add('/api', priority: 0.2, changefreq: 'monthly')
      add('/faq', priority: 0.2, changefreq: 'monthly')
      add('/privacy_policy', priority: 0.2, changefreq: 'monthly')
      add('/tos', priority: 0.2, changefreq: 'monthly')
      add('/jobs', priority: 0.8, changefreq: 'daily')
      add('/employers', priority: 0.7, changefreq: 'monthly')

      Protip.find_each(batch_size: 30) do |protip|
        add(protip_path(protip), lastmod: protip.updated_at, priority: 1.0)
      end

      Team.all.each do |team|
        add(teamname_path(slug: team.slug), lastmod: team.updated_at, priority: 0.9)
        team.jobs.each do |job|
          add(job_path(slug: team.slug, job_id: job.public_id), lastmod: job.updated_at, priority: 1.0)
        end
      end

      User.find_each(batch_size: 30) do |user|
        add(badge_path(user.username), lastmod: user.updated_at, priority: 0.9)
      end
    end

    SitemapGenerator::Sitemap.ping_search_engines
  end
end
