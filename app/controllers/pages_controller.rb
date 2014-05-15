class PagesController < ApplicationController
  def show
    show_pages_params = params.permit(:page, :layout)
    render action: show_pages_params[:page], layout: (show_pages_params[:layout] || 'application')
  end
end
