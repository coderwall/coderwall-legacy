# encoding: utf-8

class Callbacks::HawtController < ApplicationController
  before_action :authenticate
  before_action :set_default_response_format
  layout nil
  protect_from_forgery with: :null_session
  respond_to :json

  # POST                  /callbacks/hawt/feature(.:format)
  def feature
    logger.ap(params, :debug)

    feature!(hawt_callback_params[:protip_id], hawt_callback_params[:hawt?])

    respond_to do |format|
      format.json { render json: { token: hawt_callback_params[:token]} }
    end
  end

  # POST                  /callbacks/hawt/unfeature(.:format)
  def unfeature
    unfeature!(hawt_callback_params[:protip_id], hawt_callback_params[:hawt?])

    respond_to do |format|
      format.json { render json: { token: hawt_callback_params[:token]} }
    end
  end

  protected

  def feature!(protip_id, im_hawt)
    if im_hawt
      @protip = Protip.find(protip_id)
      @protip.feature
      @protip.save!
    else
      unfeature!(protip_id, im_hawt)
    end
  end

  def unfeature!(protip_id, im_hawt)
    @protip = Protip.find(protip_id)
    @protip.unfeature
    @protip.save!
  end

  def set_default_response_format
    request.format = :json
  end

  def hawt_callback_params
    @hawt_callback_params ||= params.dup.slice(:protip_id, :hawt?, :token)
  end

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV['HTTP_AUTH_USERNAME'] && password == ENV['HTTP_AUTH_PASSWORD']
    end
  end
end
