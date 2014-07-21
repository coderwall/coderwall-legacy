class BaseAdminController < ApplicationController
  layout 'admin'
  before_filter :require_admin!
end
