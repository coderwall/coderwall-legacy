class BaseAdminController < ApplicationController
  layout 'admin'
  before_action :require_admin!
end
