require_relative "base_component"
require_relative "../lib/page"
require_relative "../concerns/parallel"

module Components
  class SetProjectsProgress < BaseComponent
    include Parallel

    def get_pages
      pages_with_not_actual_progress.map do |page|
        Page.new(
          page: page,
          new_props: {
            properties: properties(format_progress(@done_percent[page.id]))
          }
        )
      end
    end

    private

    def pages_with_not_actual_progress
      pages = []
      @done_percent = {}

      iterate_over_parallel(project_pages) do |mutex, project_page|
        page_done_percent = calculate_done_percent(project_page)

        mutex.synchronize do
          @done_percent[project_page.id] = page_done_percent

          pages << project_page if project_page.properties["Progress"].rich_text.empty? ||
            project_page.properties["Progress"].rich_text.first.text.content != format_progress(page_done_percent)
        end
      end

      pages
    end

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

    def calculate_done_percent(page)
      finished_related_pages(page).count / related_pages(page).count.to_f
    end

    def finished_related_pages(page)
      client.database_query(id: ENV["DATABASE_ID"], filter: {
        and: [
          {
            property: "Folder",
            select: {
              equals: "Done"
            }
          },
          {
            property: "Родительская задача",
            relation: {
              contains: page.id
            }
          }
        ]
      }).results
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
