class CommentsController < ApplicationController

  before_action :access_required, only: [:update, :destroy]
  before_action :lookup_comment, only: [:edit, :update, :destroy, :like]
  before_action :verify_ownership, only: [:edit, :update, :destroy]
  before_action :lookup_protip, only: [:create]

  def create
    create_comment_params = params.require(:comment).permit(:comment)

    redirect_to_signup_if_unauthenticated(request.referer + "?" + (create_comment_params.try(:to_query) || ""), "You must signin/signup to add a comment") do
      @comment = @protip.comments.build(create_comment_params)

      @comment.user = current_user
      @comment.request_format = request.format.to_s

      if @comment.save
        record_event('created comment')
        format.html { redirect_to protip_path(params[:protip_id]) }
        format.json { render json: @comment, status: :created, location: @comment }
      else
        format.html { redirect_to protip_path(params[:protip_id]), error: "could not add your comment. try again" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    update_comment_params = params.require(:comment).permit(:comment)

    respond_to do |format|
      if @comment.update_attributes(update_comment_params)
        format.html { redirect_to protip_path(params[:protip_id]) }
        format.json { head :ok }
      else
        format.html { redirect_to protip_path(params[:protip_id]), error: "could not update your comment. try again" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    return head(:forbidden) if @comment.nil?
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to @protip }
      format.json { head :ok }
    end
  end

  def like
    redirect_to_signup_if_unauthenticated(request.referer, "You must signin/signup to like a comment") do
      @comment.like_by(current_user)
      record_event('liked comment')
      respond_to do |format|
        format.json { head :ok }
      end
    end
  end

  private

  def lookup_comment
    @comment = Comment.find(params[:id])
    lookup_protip
  end

  def lookup_protip
    @protip = Protip.find_by_public_id(params[:protip_id])
  end

  def verify_ownership
    redirect_to(root_url) unless (is_admin? or (@comment && @comment.authored_by?(current_user)))
  end
end
