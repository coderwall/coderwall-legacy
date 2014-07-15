module EventsHelper
  def latest_relevant_featured_protips(count)
    Protip.where(featured: true).tagged_with(current_user.networks.map(&:tags).flatten.uniq).order('featured_at DESC').limit(count)
  end

  def latest_relevant_featured_protips_based_on_skills(count)
    Protip.featured.joins("inner join taggings on taggable_id = protips.id and taggable_type = 'Protip'").joins('inner join tags on taggings.tag_id = tags.id').where('tags.id IN (?)', ActiveRecord::Base.connection.select_values(current_user.skills.joins('inner join tags on UPPER(tags.name)=UPPER(skills.name)').select('tags.id'))).limit(count)
  end
end
