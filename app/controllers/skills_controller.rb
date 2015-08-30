class SkillsController < ApplicationController

  # POST                  /users/:user_id/skills(.:format)
  def create
    @user = (params[:user_id] && User.find(params[:user_id])) || current_user
    return head(:forbidden) unless current_user == @user
    if params[:skill][:name] == "skills separated by comma"
      skill_names = []
    else
      skill_names = params[:skill][:name].split(",")
    end
    correct_skill_names = []
    skill_names.each do |skill_name|
      skill_name = ActionController::Base.helpers.sanitize(skill_name)
      skill      = @user.add_skill(skill_name)
      unless skill.nil?
        correct_skill_names << skill.name
      end
    end
    if correct_skill_names.blank?
      flash[:error] = "Hmm...couldn't recognize '#{skill_names.flatten.join(',')}'"
    else
      flash[:notice] = "Whoa...you're good at #{correct_skill_names.to_sentence}? Awesome!"
    end
    redirect_to(badge_url(username: @user.username))
  end

  # DELETE                /users/:user_id/skills/:id(.:format)
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
