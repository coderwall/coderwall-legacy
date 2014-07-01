class BaseAdminController < ApplicationController
  before_filter :require_admin!
end
