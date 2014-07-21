namespace :cleanup do

  namespace :protips do
    # PRODUCTION: RUNS DAILY
    task :associate_zombie_upvotes => :environment do
      Like.joins('inner join users on users.tracking_code = likes.tracking_code').where('likes.tracking_code is not null').where(:user_id => nil).find_each(:batch_size => 1000) do |like|
        ProcessLikeJob.perform_async(:associate_to_user, like.id)
      end
    end

    #task :duplicate_tags => :environment do
      #Tag.select('name, count(name)').group(:name).having('count(name) > 1').map(&:name).each do |tag_name|
        #duplicate_tags = Tag.where(:name => tag_name).map(&:id)
        #original_tag = duplicate_tags.shift
        #while (duplicate_tag = duplicate_tags.shift)
          #enqueue(MergeTag, original_tag, duplicate_tag)
          #Tag.find(duplicate_tag).destroy
        #end
      #end
    #end

    #task :duplicate_slideshares => :environment do
      #ProtipLink.select('url, count(url)').group(:url).having('count(url) > 1').where("url LIKE '%www.slideshare.net/slideshow/embed_code%'").map(&:url).each do |link|
        #enqueue(MergeDuplicateLink, link)
      #end
    #end

    #task :zombie_taggings => :environment do
      #Tagging.where('tag_id not in (select id from tags)').find_each(:batch_size => 1000) do |zombie_tagging|
        #zombie_tagging.destroy
      #end
    #end

    #task :delete_github_protips => :environment do
      #Protip.where(:created_by => "coderwall:importer").find_each(:batch_size => 1000) do |protip|
        #if protip.topics.include? "github"
          #enqueue(ProcessProtip, :delete, protip.id)
        #end
      #end
    #end

    #task :queue_orphan_protips => :environment do
      #network_tags = Network.all.collect(&:tags).flatten
      #Protip.where('id NOT IN (?)', Protip.any_topics(network_tags).select(:id)+Protip.tagged_with("slideshare")).select([:id, :public_id]).find_each(:batch_size => 1000) do |protip|
        #Event.send_admin_notifications(:new_protip, {:public_id => protip.public_id}, :orphan_protips)
      #end
    #end

    #task :retag_space_delimited_tags => :environment do
      #Protip.joins("inner join taggings on taggable_id = protips.id and taggable_type = 'Protip'").where("taggings.context = 'topics'").select("protips.*").group('protips.id').having('count(protips.id) = 1').each do |protip|
        #protip.save if protip.topics.first =~ /\s/
      #end
    #end

    #namespace :downvote do
      #task :github_links_protips => :environment do
        #Protip.where('LENGTH(body) < 300').where("body LIKE '%https://github.com%'").each do |protip|
          #protip.likes.where('value < 20').delete_all
          #enqueue(ProcessProtip, :recalculate_score, protip.id)
        #end
      #end
    #end
  end

  #namespace :skills do
    #task :merge => :environment do
      #SKILLS = {'objective c' => 'objective-c'}

      #SKILLS.each do |incorrect_skill, correct_skill|
        #Skill.where(:name => incorrect_skill).each do |skill|
          #puts "merging skill"
          #enqueue(MergeSkill, skill.id, correct_skill)
        #end
      #end
    #end

    #task :duplicates => :environment do
      #Skill.group('lower(name), user_id').having('count(user_id) > 1').select('lower(name) as name, user_id').each do |skill|
        #skills = Skill.where('lower(name) = ?', skill.name).where(:user_id => skill.user_id)
        #skill_to_keep = skills.shift
        #skills.each do |skill_to_delete|
          #skill_to_delete.endorsements.each do |endorsement|
            #skill_to_keep.endorsements << endorsement
          #end
        #end
        #skill_to_keep.save
        #skills.destroy_all
      #end
    #end
  #end

  #namespace :teams do
    #task :remove_deleted_teams_dependencies => :environment do
      #valid_team_ids = Team.only(:id).all.map(&:_id).map(&:to_s)
      #[FollowedTeam, Invitation, Opportunity, SeizedOpportunity, User].each do |klass|
        #puts "deleting #{klass.where('team_document_id IS NOT NULL').where('team_document_id NOT IN (?)', valid_team_ids).count} #{klass.name}"
        #if klass == User
          #klass.where('team_document_id IS NOT NULL').where('team_document_id NOT IN (?)', valid_team_ids).update_all('team_document_id = NULL')
        #else
          #klass.where('team_document_id IS NOT NULL').where('team_document_id NOT IN (?)', valid_team_ids).delete_all
        #end
      #end
    #end
  #end
end
