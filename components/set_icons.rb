require 'yaml'
require_relative "base_component"

module Components
  class SetIcons < BaseComponent
    def pages_with_properties_for_update
      filters_with_icons = YAML.load_file("fixtures/icons_conditions.yml")

      filters_with_icons.flat_map do |item|
        pages = client.database_query(id: ENV["DATABASE_ID"], filter: item["filter"]).results

        pages.select! do |page|
          page.icon.to_h != item["icon"]
        end

        pages.map do |page|
          {
            page: page,
            new_properties: {
              icon: item["icon"]
            }
          }
        end
      end
    end
  end
end
