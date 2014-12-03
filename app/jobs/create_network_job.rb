class CreateNetworkJob
  include Sidekiq::Worker

  sidekiq_options queue: :network

  def perform(tag)
    top_tags = Protip.trending_topics
    sub_tags = Protip.tagged_with([tag], on: :topics).flat_map(&:topics)
    sub_tags.delete_if { |sub_tag| top_tags.include? sub_tag }
    unless sub_tags.blank?
      sub_tag_frequency = sub_tags.inject(Hash.new(0)) { |h, sub_tag| h[sub_tag] += 1; h }
      sub_tags = sub_tags.uniq.sort_by { |sub_tag| -sub_tag_frequency[sub_tag] }
      Network.create(name: tag, tags: sub_tags)
    end
  end
end
