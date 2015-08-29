class PagesController < ApplicationController

  # GET                   /faq(.:format)
  # GET                   /tos(.:format)
  # GET                   /privacy_policy(.:format)
  # GET                   /contact_us(.:format)
  # GET                   /api(.:format)
  # GET                   /achievements(.:format)
  # GET                   /pages/:page(.:format)
  def show
    show_pages_params = params.permit(:page, :layout)

    page_to_show = whitelist_page(show_pages_params[:page])

    render action: page_to_show, layout: whitelist_layout(show_pages_params[:layout])
  end

  private

  # Checks whether the requested_page exists in app/views/pages/*.html.haml
  def whitelist_page(requested_page)
    raise ActionController::RoutingError.new('Not Found') unless ::STATIC_PAGES.include?(requested_page.to_s)

    requested_page
  end

  def whitelist_layout(requested_layout)
    return 'application' if requested_layout.nil?

    raise ActionController::RoutingError.new('Not Found') unless ::STATIC_PAGE_LAYOUTS.include?(requested_layout.to_s)

    requested_layout
  end
end
