module UserJob
  extend ActiveSupport::Concern

  def apply_to(job)
    job.apply_for(self)
  end

  def already_applied_for?(job)
    job.seized_by?(self)
  end

  def has_resume?
    resume.present?
  end
end