# == Schema Information
#
# Table name: teams
#
#  id                     :integer          not null, primary key
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  website                :string(255)
#  about                  :text
#  total                  :integer          default(0)
#  size                   :integer          default(0)
#  mean                   :integer          default(0)
#  median                 :integer          default(0)
#  score                  :integer          default(0)
#  twitter                :string(255)
#  facebook               :string(255)
#  slug                   :string(255)
#  premium                :boolean          default(FALSE)
#  analytics              :boolean          default(FALSE)
#  valid_jobs             :boolean          default(FALSE)
#  hide_from_featured     :boolean          default(FALSE)
#  preview_code           :string(255)
#  youtube_url            :string(255)
#  github                 :string(255)
#  highlight_tags         :string(255)
#  branding               :text
#  headline               :text
#  big_quote              :text
#  big_image              :string(255)
#  featured_banner_image  :string(255)
#  benefit_name_1         :text
#  benefit_description_1  :text
#  benefit_name_2         :text
#  benefit_description_2  :text
#  benefit_name_3         :text
#  benefit_description_3  :text
#  reason_name_1          :text
#  reason_description_1   :text
#  reason_name_2          :text
#  reason_description_2   :text
#  reason_name_3          :text
#  reason_description_3   :text
#  why_work_image         :text
#  organization_way       :text
#  organization_way_name  :text
#  organization_way_photo :text
#  office_photos          :string(255)      default("{}")
#  upcoming_events        :string(255)      default("{}")
#  featured_links_title   :string(255)
#  blog_feed              :text
#  our_challenge          :text
#  your_impact            :text
#  interview_steps        :string(255)      default("{}")
#  hiring_tagline         :text
#  link_to_careers_page   :text
#  avatar                 :string(255)
#  achievement_count      :integer          default(0)
#  endorsement_count      :integer          default(0)
#  invited_emails         :string(255)      default("{}")
#  admins                 :string(255)      default("{}")
#  editors                :string(255)      default("{}")
#  pending_join_requests  :string(255)      default("{}")
#  upgraded_at            :datetime
#  paid_job_posts         :integer          default(0)
#  monthly_subscription   :boolean          default(FALSE)
#  stack_list             :text             default("")
#  number_of_jobs_to_show :integer          default(2)
#  location               :string(255)
#  country_id             :integer
#

Fabricator(:pg_team) do
end
