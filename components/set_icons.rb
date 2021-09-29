require 'yaml'
require_relative "base_component"

module Components
  class SetIcons < BaseComponent
    def call
      filters_with_icons = YAML.load_file("fixtures/icons_conditions.yml")

      filters_with_icons.each do |inst|
        pages = client.database_query(id: ENV["DATABASE_ID"], filter: inst["filter"]).results

        req_pages = pages.select do |page|
          page.icon.to_h != inst["icon"]
        end

        update_pages(req_pages, icon: inst["icon"])
      end
    end
  end
end
