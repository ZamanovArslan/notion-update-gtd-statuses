require "byebug"
class UpdatesOptimizer
  attr_reader :pages

  def initialize(pages)
    @pages = pages
  end

  def get_pages
    pages.group_by(&:id).map do |(id, same_pages)|
      Page.new(page: same_pages.first.page, new_props: merged_props(same_pages))
    end
  end

  private

  def merged_props(pages)
    pages.reduce({}) do |accum, page|
      accum.merge page.new_props
    end
  end
end
