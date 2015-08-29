class ErrorsController < ApplicationController

  # GET|POST|PATCH|DELETE /404(.:format)
  def not_found
    render status: :not_found
  end

  # GET|POST|PATCH|DELETE /422(.:format)
  def unacceptable
    respond_to do |format|
      format.html { render 'public/422', status: :unprocessable_entity }
      format.xml  { head :unprocessable_entity }
      format.json { head :unprocessable_entity }
    end
  end

  # GET|POST|PATCH|DELETE /500(.:format)
  def internal_error
    respond_to do |format|
      format.html { render 'public/500', status: :internal_server_error }
      format.xml  { head :internal_server_error }
      format.json { head :internal_server_error }
    end
  end
end
