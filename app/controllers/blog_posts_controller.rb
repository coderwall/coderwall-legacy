class BlogPostsController < ApplicationController
  skip_before_filter :require_registration

  def index
    @blog_posts = BlogPost.all_public[0..5]
    respond_to do |f|
      f.html
      f.atom
    end
  end

  def show
    @blog_post = BlogPost.find(params[:id])
  rescue BlogPost::PostNotFound => e
    return head(:not_found)
  end
end