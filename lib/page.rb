class Page
  attr_reader :page, :new_props

  def initialize(page:, new_props:)
    @page = page
    @new_props = new_props
  end

  def id
    page.id
  end
end
