require "yaml"
require_relative "base_component"
require_relative "../lib/page"

module Components
  class SetIcons < BaseComponent
    def get_pages
      filters_with_icons = YAML.load_file("fixtures/icons_conditions.yml")

      filters_with_icons.flat_map do |item|
        pages = client.database_query(id: ENV["DATABASE_ID"], filter: item["filter"]).results

        pages.select! do |page|
          page.icon.to_h != item["icon"]
        end

        pages.map do |page|
          Page.new(
            page: page,
            new_props: {
              icon: item["icon"]
            }
          )
        end
      end
    end
  end
end
