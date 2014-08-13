class ResumeUploadsController < ApplicationController

  before_action :access_required

  # POST /resume_uploads
  # Non standard resource controller
  # Expected params:
  # @param [ String|Integer ]   user_id - User id to attach resume
  # @param [ File ]             resume - Resume file uploaded via file field
  def create
    user = User.find params[:user_id]
    user.resume = params[:resume]
    
    if user.save!
      respond_to do |format|
        format.html { redirect_to :back, notice: "Your resume has been uploaded." }
        format.js   { head :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to :back, notice: "There was an error uploading your resume." }
        format.js   { head :unprocessable_entity }
      end
    end

  end

end
