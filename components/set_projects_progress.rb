require_relative "base_component"
require_relative "../lib/page"

module Components
  class SetProjectsProgress < BaseComponent
    def get_pages
      not_actual_progress_pages = project_pages.select do |page|
        next true if page.properties["Progress"].rich_text.empty?

        page.properties["Progress"].rich_text.first.text.content != format_progress(done_percent(page))
      end

      not_actual_progress_pages.map do |page|
        Page.new(
          page: page,
          new_props: {
            properties: properties(format_progress(done_percent(page)))
          }
        )
      end
    end

    private

    def project_pages
      @project_pages ||= client.database_query(id: ENV["DATABASE_ID"], filter: filter).results
    end

    def filter
      {
        property: "Folder",
        select: {
          equals: "Projects"
        }
      }
    end

    def properties(progress)
      {
        "Progress": {
          "type": "rich_text",
          "rich_text": [
            {
              "type": "text",
              "text": { "content": progress }
            }
          ]
        }
      }
    end

    def done_percent(page)
      @done_percent ||= {}
      @done_percent[page.id] ||= finished_related_pages(page).count / related_pages(page).count.to_f
    end

    def finished_related_pages(page)
      related_pages(page).select do |page|
        @client.page(id: page.id).properties["Folder"]["select"].name == "Done"
      end
    end

    def related_pages(page)
      page.properties["Одношаговые подзадачи"].relation
    end

    def format_progress(percent)
      progress_icon_left = case (percent * 10).to_i
        when 0...3
          ENV["PROGRESS_ICON_RED"]
        when 3...5
          ENV["PROGRESS_ICON_ORANGE"]
        when 5...9
          ENV["PROGRESS_ICON_YELLOW"]
        when 9..10
          ENV["PROGRESS_ICON_GREEN"]
      end

      (progress_icon_left * (percent * 10).to_i).ljust(10, ENV["PROGRESS_ICON_RIGHT"])
    end
  end
end
