require_relative "base_component"

module Components
  class SetProjectsProgress < BaseComponent
    def pages_with_properties_for_update
      not_actual_progress_pages = project_pages.select do |page|
        page.properties["Progress"].rich_text.first.text.content != format_progress(done_percent(page))
      end
      
      not_actual_progress_pages.map do |page|
        {
          page: page,
          new_properties: {
            properties: properties(format_progress(done_percent(page)))
          }
        }
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
      (ENV["PROGRESS_ICON_LEFT"] * (percent * 10).to_i).ljust(10, ENV["PROGRESS_ICON_RIGHT"])
    end
  end
end
