class LinksController < BaseAdminController
  def index
    @links1, @links2, @links3 = *Link.featured.popular.limit(100).all.chunk(3)
  end

  def suppress
    Link.find(params[:id]).suppress!
  end
end
