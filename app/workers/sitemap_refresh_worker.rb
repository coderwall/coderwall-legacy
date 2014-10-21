class SitemapRefreshWorker
  include Sidekiq::Worker

  sidekiq_options queue: :sitemap_generator

  def perform
    SitemapGenerator::Sitemap.default_host  = 'https://coderwall.com'
    SitemapGenerator::Sitemap.public_url    = 'tmp/'
    SitemapGenerator::Sitemap.sitemaps_host = "http://#{ENV['FOG_DIRECTORY']}.s3.amazonaws.com/"
    SitemapGenerator::Sitemap.sitemaps_url  = 'sitemaps/'
    SitemapGenerator::Sitemap.adapter       = SitemapGenerator::WaveAdapter.new

    SitemapGenerator::Sitemap.create do
      add('https://coderwall.com/welcome', priority: 0.7, changefreq: 'monthly')
      add('https://coderwall.com/contact_us', priority: 0.2, changefreq: 'monthly')
      add('https://coderwall.com/blog', priority: 0.5, changefreq: 'weekly')
      add('https://coderwall.com/api', priority: 0.2, changefreq: 'monthly')
      add('https://coderwall.com/faq', priority: 0.2, changefreq: 'monthly')
      add('https://coderwall.com/privacy_policy', priority: 0.2, changefreq: 'monthly')
      add('https://coderwall.com/tos', priority: 0.2, changefreq: 'monthly')
      add('https://coderwall.com/jobs', priority: 0.8, changefreq: 'daily')
      add('https://coderwall.com/employers', priority: 0.7, changefreq: 'monthly')

      Protip.find_each(batch_size: 30) do |protip|
        add(protip_url(protip), lastmod: protip.updated_at, priority: 1.0)
      end

      Team.all.each do |team|
        add(teamname_url(slug: team.slug), lastmod: team.updated_at, priority: 0.9)
        team.jobs.each do |job|
          add(job_url(slug: team.slug, job_id: job.public_id), lastmod: job.updated_at, priority: 1.0)
        end
      end

      User.find_each(batch_size: 30) do |user|
        add(badge_url(user.username), lastmod: user.updated_at, priority: 0.9)
      end

      BlogPost.all_public.each do |blog_post|
        add(blog_post_url(blog_post.id), lastmod: blog_post.posted, priority: 0.5)
      end
    end

    SitemapGenerator::Sitemap.ping_search_engines
  end
end
