class PagesController < ApplicationController
  def show
    render action: params[:page], layout: (params[:layout] || 'application')
  end
end