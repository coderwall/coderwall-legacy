class MergeSkillJob
  include Sidekiq::Worker

  sidekiq_options queue: :data_cleanup

  def perform(incorrect_skill_id, correct_skill_name)
    incorrect_skill = Skill.find(incorrect_skill_id)
    correct_skill = incorrect_skill.user.skills.where(name: correct_skill_name).first

    if correct_skill.nil?
      incorrect_skill.name = correct_skill_name
      incorrect_skill.save!
    else
      correct_skill.merge_with(incorrect_skill)
      correct_skill.save!
      incorrect_skill.destroy
    end
  end
end
