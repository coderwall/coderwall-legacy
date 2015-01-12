module PremiumHelper

  def markdown(text)
    return nil if text.nil?
    Kramdown::Document.new(text).to_html.gsub(/<p>|<\/p>/, '').html_safe
  end

  def inactive_box(section_id, title, &block)
    haml_tag(:div, class: 'inactive-box') do
      haml_tag(:h2) do
        haml_concat("#{title} Inactive")
      end
      haml_tag(:p) do
        # haml_concat(yield.to_s.gsub('1', '').gsub('2', ''))
        haml_concat(capture_haml(&block))
      end
      haml_tag(:a, href: section_id, class: 'activate-editor') do
        haml_concat('Activate')
      end
    end
  end

  def admin_hint(&block)
    haml_tag(:div, class: 'hint') do
      haml_tag(:h3) do
        haml_concat("Pro tip")
      end
      haml_tag(:p) do
        haml_concat(capture_haml(&block))
      end
    end
  end

  def ideas_list(&block)
    haml_tag(:div, class: 'ideas') do
      haml_tag(:h3) do
        haml_concat("Some ideas")
      end
      haml_tag(:ul) do
        haml_concat(capture_haml(&block))
      end
    end
  end

  def panel_form_for_section(section_id, title = nil, show_save_button = true, &block)
    haml_tag(:div, class: 'edit') do
      haml_concat link_to('edit', section_id, class: 'launch-editor')
    end
    haml_tag(:div, class: 'form hide cf') do
      haml_concat link_to(' ', section_id, class: 'close-editor circle')
      haml_concat(form_for(@team, remote: true) do |f|
        haml_tag(:ul, class: 'errors') do
          # haml_tag(:li) do
          #   haml_concat 'Here is a fake error message for oli to style. There may be many and there may be none'
          # end if Rails.env.development?
        end
        haml_tag(:header) do
          haml_tag(:h2) do
            haml_concat(title)
          end
        end
        haml_concat(capture_haml(f, &block))
        haml_concat(hidden_field_tag(:section_id, section_id))
        haml_tag(:footer) do
          haml_concat(f.submit('Save')) if show_save_button
          haml_concat link_to('Close', section_id, class: 'close-editor')
        end
      end)
    end
  end

  def partialify_html_section_id(section_id)
    section_id.to_s.tr("-", "_").gsub('#', '')
  end

  def add_active_class_to_first_member
    return nil if @add_active_class_to_first_member == true
    @add_active_class_to_first_member = true
    'active'
  end

  def show_or_hide_member_class
    @members_visible ||= 0
    if @members_visible < 6 && increment_members_visible
      nil
    else
      'hide'
    end
  end

  def increment_members_visible
    @members_visible = @members_visible + 1
    true
  end

  def admin_of_team?
    is_admin? || @team.admin?(current_user)
  end

  def can_edit?
    admin_of_team? and @edit_mode
  end

  def section_enabled_class(check)
    return 'inactive' if !check
  end

  def apply_css(current_user, job)
    current_user.try(:already_applied_for?, job) ? "apply applied" : "apply"
  end

  def only_on_first(number, hash)
    number == 1 ? hash : {}
  end

  def job_activation_css(job)
    job.active? ? "active-opportunity" : "inactive-opportunity"
  end

  def activate_or_deactivate(job)
    job.active? ? 'deactivate' : 'activate'
  end

  def big_quote_or_default(team)
    !team.big_quote.blank? ? team.big_quote : "Quotes from a team member about culture or an accomplishment"
  end

  def big_image_or_default(team)
    if !team.big_image.blank?
      team.big_image
    else
      can_edit? ? 'premium-teams/stock_office.jpg' : banner_image_or_default(team)
    end
  end

  def headline_or_default(team)
    !team.headline.blank? ? team.headline : "What defines engineering at #{team.name}?"
  end

  def organization_way_photo_or_default(team)
    !team.organization_way_photo.blank? ? team.organization_way_photo : 'premium-teams/stock_cardwall.jpeg'
  end

  def organization_way_name_or_default(team)
    !team.organization_way_name.blank? ? team.organization_way_name : 'This is how we roll'
  end

  def organization_way_or_default(team)
    !team.organization_way.blank? ? team.organization_way : 'How does the organization run? What values help you accomplish your goals?'
  end

  def why_work_image_or_default(team)
    !team.why_work_image.blank? ? team.why_work_image : 'premium-teams/stock_setup.jpeg'
  end

  def office_photos_or_default(team)
    !team.office_photos.blank? ? team.office_photos : [
        'premium-teams/stock-dogs-ok.jpg',
        'premium-teams/stock-wall-of-macs.jpeg',
        'premium-teams/stock-office-upon-office.jpg'
    ]
  end

  def interview_steps_or_default(team)
    !team.interview_steps.blank? ? team.interview_steps : [
        'What is the first thing you want candidates to do?',
        'Arrange a 30 minute phone screen?'
    ]
  end

  def hiring_tagline_or_default(team)
    !team.hiring_tagline.blank? ? team.hiring_tagline : 'Come build great software with us'
  end

  def jobs_or_default(team, except_job=nil)
    !team.jobs.blank? ? (team.jobs - [except_job]).first(team.number_of_jobs_to_show) : [default_job]
  end

  def default_job
    Opportunity.new(
        name: 'Engineer',
        description: 'Help us create an amazing product',
        location: 'Anywhere',
        link: 'http://coderwall.com',
        cached_tags: 'Skilled, Awesome',
        tag_list: %w(Java TDD Heroku),
        location_city: 'San Francisco, CA',
        team_id: @team.id || Team.featured.first.id
    )
  end

  def stack_or_default(team)
    team.has_stack? ? team.stack.first(8) : ["jQuery", "Ruby", "Postgresql", "Heroku", "R", "Machine Learning"]
  end

  def team_job_size(team)
    return 1 if team.jobs.size == 0
    [team.jobs.size, team.number_of_jobs_to_show].min
    #1
  end

  def your_impact_or_default(team)
    !team.your_impact.blank? ? team.your_impact : 'What impact would the individual have on the team or product?'
  end

  def our_challenge_or_default(team)
    !team.our_challenge.blank? ? team.our_challenge : 'What is the biggest challenge the team is working on?'
  end

  def has_impact?(team)
    team.our_challenge.blank? || !team.your_impact.blank?
  end

  def reason_name_1_or_default(team)
    !team.reason_name_1.blank? ? team.reason_name_1 : "List the reasons why #{team.name} is unique?"
  end

  def reason_description_1_or_default(team)
    !team.reason_name_1.blank? ? team.reason_description_1 : "Share up to 3 reasons why its great to work on the #{team.name} team."
  end

  def job_visited(job)
    visit_team_opportunity_path(job.team_id, job.id) unless job.new_record?
  end

  def link_to_add_fields(name, form, association)
    new_object = form.object.class.reflect_on_association(association).klass.new
    fields = form.fields_for(association, new_object, child_index: "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
  end

  def blog_content(entry)
    truncate(Sanitize.clean(entry.summary || entry.content || "").first(400), length: 300)
  end

  def application_status_css(job)
    current_user.already_applied_for?(job) ? "send-application applied" : "send-application"
  end

  def apply_url(job)
    current_user.already_applied_for?(job) ? "#already-applied" : apply_team_opportunity_path(job.team, job)
  end

  def highly_interested?(visitor, team)
    ((visitor[:time_spent].to_i/1000).seconds > 60 && team.sections_up_to(visitor[:furthest_scrolled]).count > 5) || visitor[:exit_target_type] == "job-opportunity"
  end

  def can_see_analytics?
    is_admin? or (@team.analytics? && admin_of_team?)
  end

end
