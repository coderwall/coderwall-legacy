class HighlightsController < ApplicationController

  def index
    @highlight = Highlight.random.first
  end

  def create
    @badge = nil
    if current_user && !params[:highlight].blank?
      if @highlight = current_user.highlights.create!(description: params[:highlight].strip)
        badge = Beaver.new(current_user)
        if current_user.active? && badge.award? && !current_user.has_badge?(Beaver)
          begin
            @badge = current_user.award(badge)
            current_user.save!
            @badge_event = Event.create_badge_event(current_user, @badge)
            Event.create_timeline_for(current_user)
          rescue Exception => ex
            @badge = nil #if cant save we should not add achievement to page
            Rails.logger.error("Error awarding Beaver to user #{current_user.id}: #{ex.message}")
          end
        end
        @user = current_user
      end
    else
      return render js: "alert('Y YOU NO SHARE SOMETHING BEFORE SUBMITTING');"
    end
  end

  def destroy
    if current_user
      @highlight = current_user.highlights.find(params[:id])
      @badge     = nil
      if @highlight.destroy
        #record_event("highlight removed", :mp_note => @highlight.description)
        badge = Beaver.new(current_user)
        if !badge.award?
          @badge = current_user.badges.where(badge_class_name: Beaver.name).first
          @badge.destroy if @badge
        end
      end
      Event.create_timeline_for(current_user)
    end
  end

  def random
    render json: Highlight.random_featured
  end

end
