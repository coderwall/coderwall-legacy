class AddColumstoPgteam < ActiveRecord::Migration
  def up
    add_column :teams, :website, :string
    add_column :teams, :about, :text
    add_column :teams, :total, :integer, default: 0
    add_column :teams, :size, :integer, default: 0
    add_column :teams, :mean, :integer, default: 0
    add_column :teams, :median, :integer, default: 0
    add_column :teams, :score, :integer, default: 0
    add_column :teams, :twitter, :string
    add_column :teams, :facebook, :string
    add_column :teams, :slug, :string
    add_column :teams, :premium, :boolean, default: false
    add_column :teams, :analytics, :boolean, default: false
    add_column :teams, :valid_jobs, :boolean, default: false
    add_column :teams, :hide_from_featured, :boolean, default: false
    add_column :teams, :preview_code, :string
    add_column :teams, :youtube_url, :string

    add_column :teams, :github, :string

    add_column :teams, :highlight_tags, :string
    add_column :teams, :branding, :text
    add_column :teams, :headline, :text
    add_column :teams, :big_quote, :text
    add_column :teams, :big_image, :string
    add_column :teams, :featured_banner_image, :string

    add_column :teams, :benefit_name_1, :text
    add_column :teams, :benefit_description_1, :text
    add_column :teams, :benefit_name_2, :text
    add_column :teams, :benefit_description_2, :text
    add_column :teams, :benefit_name_3, :text
    add_column :teams, :benefit_description_3, :text

    add_column :teams, :reason_name_1, :text
    add_column :teams, :reason_description_1, :text
    add_column :teams, :reason_name_2, :text
    add_column :teams, :reason_description_2, :text
    add_column :teams, :reason_name_3, :text
    add_column :teams, :reason_description_3, :text
    add_column :teams, :why_work_image, :text

    add_column :teams, :organization_way, :text
    add_column :teams, :organization_way_name, :text
    add_column :teams, :organization_way_photo, :text

    add_column :teams, :office_photos, :string, array: true, default: '{}'
    add_column :teams, :upcoming_events, :string, array: true, default: '{}' #just stubbed

    add_column :teams, :featured_links_title, :string
    # embeds_many :featured_links, class_name: TeamLink.name
    # => has_many :links

    add_column :teams, :blog_feed, :text
    add_column :teams, :our_challenge, :text
    add_column :teams, :your_impact, :text

    add_column :teams, :interview_steps, :string, array: true, default: '{}'
    add_column :teams, :hiring_tagline, :text
    add_column :teams, :link_to_careers_page, :text

    add_column :teams, :avatar, :string

    add_column :teams, :achievement_count, :integer, default: 0
    add_column :teams, :endorsement_count, :integer, default: 0
    add_column :teams,  :invited_emails, :string, array: true, default: '{}'


    add_column :teams,  :admins, :string, array: true, default: '{}'
    add_column :teams, :editors, :string, array: true, default: '{}'

    add_column :teams, :pending_join_requests, :string, array: true, default: '{}'

    add_column :teams, :upgraded_at, :datetime
    add_column :teams, :paid_job_posts, :integer, default: 0
    add_column :teams, :monthly_subscription,:boolean,  default: false
    add_column :teams, :stack_list, :text, default: ''
    add_column :teams, :number_of_jobs_to_show, :integer, default: 2
    add_column :teams, :location, :string
    add_column :teams, :country_id, :integer

  end
end
