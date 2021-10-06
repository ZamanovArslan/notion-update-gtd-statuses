require "notion-ruby-client"
require "dotenv/load"
require "dry-configurable"
require_relative "components/set_icons"
require_relative "components/set_projects_progress"
require_relative "lib/updates_optimizer"
require_relative "concerns/parallel"

class NotionUpdateGtdStatuses
  extend Dry::Configurable
  extend Parallel

  setting :components, [Components::SetIcons]
  setting :notion_client, Notion::Client.new(token: ENV["SECRET_TOKEN"])

  def self.run
    progressbar = ProgressBar.create(title: "Updating pages")

    pages = UpdatesOptimizer.new(recieve_pages_parallel).get_pages

    progressbar.total = pages.size

    update_pages_parallel(pages, progressbar)
  end

  def self.recieve_pages_parallel
    pages = []

    iterate_over_parallel(config.components) do |mutex, component|
      new_pages = component.new(config.notion_client).get_pages

      mutex.synchronize do
        pages.concat new_pages
      end
    end
    pages
  end

  def self.update_pages_parallel(pages, progressbar)
    iterate_over_parallel(pages) do |mutex, page|
      config.notion_client.update_page(id: page.id, **page.new_props)

      mutex.synchronize do
        progressbar.increment
      end
    end
  end
end
