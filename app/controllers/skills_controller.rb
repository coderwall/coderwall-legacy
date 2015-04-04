class SkillsController < ApplicationController

  def create
    @user = (params[:user_id] && User.find(params[:user_id])) || current_user
    return head(:forbidden) unless current_user == @user
    if params[:skill][:name] == "skills separated by comma"
      skill_names = []
    else
      skill_names = params[:skill][:name].split(",")
    end
    invalid_skill_names = []
    duplicate_skill_names = []
    added_skill_names = []
    skill_names.each do |skill_name|
      skill_name = ActionController::Base.helpers.sanitize(skill_name)
      duplicate = false
      if @user.skill_for(skill_name)
        duplicate = true
        duplicate_skill_names << skill_name
      end
      skill = @user.add_skill(skill_name)
      if !skill.nil?
          if !duplicate
            added_skill_names << skill.name
          end
      else
        invalid_skill_names << skill_name
      end
    end
    empty_input_msg = "Hmm...couldn't recognize '#{skill_names.flatten.join(',')}'."
    invalid_msg = "Hmm...couldn't recognize '#{invalid_skill_names.flatten.join(',')}'."
    duplicate_msg = "Oops, you've already added #{duplicate_skill_names.flatten.join(' and ')} to your skills."
    added_msg = "Whoa...you're good at #{added_skill_names.to_sentence}? Awesome!"
    if added_skill_names.blank?
      if duplicate_skill_names.blank? && invalid_skill_names.blank?
        flash[:error] = empty_input_msg
      elsif !duplicate_skill_names.blank? && !invalid_skill_names.blank?
        flash[:error] = duplicate_msg + " " + invalid_msg
      elsif !duplicate_skill_names.blank?
        flash[:error] = duplicate_msg
      else
        flash[:error] = invalid_msg
      end
    else
      flash[:notice] = added_msg
      if !duplicate_skill_names.blank?
        flash[:notice] += " " + duplicate_msg
      end
      if !invalid_skill_names.blank?
        flash[:notice] += " " + invalid_msg
      end
    end
    redirect_to(badge_url(username: @user.username))
  end

  def destroy
    redirect_to_signup_if_unauthenticated do
      @skill = current_user.skills.find(params[:id])
      if @skill

        #record_event('deleted skill', :skill => @skill.tokenized)
        flash[:notice] = "Ok got it...you're no longer into #{@skill.name}"
        @skill.destroy
        redirect_to(badge_url(username: @skill.user.username))
      end
    end
  end

end
