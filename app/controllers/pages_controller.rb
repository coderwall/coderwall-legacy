class PagesController < ApplicationController
  def show
    show_pages_params = params.permit(:page, :layout)

    page_to_show = whitelist_page(show_pages_params[:page])

    render action: page_to_show, layout: whitelist_layout(show_pages_params[:layout])
  end

  private

  # Checks whether the requested_page exists in app/views/pages/*.html.haml
  def whitelist_page(requested_page)
    fail "Invalid page: #{requested_page}" unless ::STATIC_PAGES.include?(requested_page.to_s)

    requested_page
  end

  def whitelist_layout(requested_layout)
    return 'application' if requested_layout.nil?

    fail "Invalid layout: #{requested_layout}" unless ::STATIC_PAGE_LAYOUTS.include?(requested_layout.to_s)

    requested_layout
  end
end
