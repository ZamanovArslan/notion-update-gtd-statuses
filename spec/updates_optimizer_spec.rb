require_relative "../lib/updates_optimizer"
require_relative "../lib/page"

RSpec.describe UpdatesOptimizer do
  subject(:updates_optimizer) { UpdatesOptimizer.new(pages) }

  let(:pages) do
    [page_1, page_2, page_3]
  end
  let(:page_1) do
    Page.new(page: page_1_double, new_props: { icon: "123" })
  end
  let(:page_2) do
    Page.new(page: page_1_double, new_props: { properties: { test: "test" } })
  end
  let(:page_3) do
    Page.new(page: page_2_double, new_props: { properties: { test: "new" } })
  end
  let(:page_1_double) { double("NotionPage", id: 1) }
  let(:page_2_double) { double("NotionPage", id: 2) }

  describe "#get_pages" do
    it "squash props for same pages" do
      expect(updates_optimizer.get_pages.first).to have_attributes(
        id: 1,
        page: page_1_double,
        new_props: { icon: "123", properties: { test: "test" } }
      )
    end
  end
end
