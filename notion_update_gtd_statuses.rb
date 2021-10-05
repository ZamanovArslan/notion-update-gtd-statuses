require "notion-ruby-client"
require "dotenv/load"
require "dry-configurable"
require_relative "components/set_icons"
require_relative "components/set_projects_progress"
require_relative "lib/updates_optimizer"
require 'byebug'
require 'thread'  # for Mutex

class NotionUpdateGtdStatuses
  extend Dry::Configurable

  setting :components, [Components::SetIcons]
  setting :notion_client, Notion::Client.new(token: ENV["SECRET_TOKEN"])

  def self.run
    progressbar = ProgressBar.create(title: "Updating pages")

    pages = UpdatesOptimizer.new(recieve_pages_parallel).get_pages

    progressbar.total = pages.size

    update_pages_parallel(pages, progressbar)
  end

  def self.update_pages_parallel(pages, progressbar)
    mutex = Mutex.new

    ENV["THREADS_COUNT"].to_i.times.map do
      Thread.new(pages) do |pages|
        while page = mutex.synchronize { pages.pop }
          config.notion_client.update_page(id: page.id, **page.new_props)

          mutex.synchronize do
            progressbar.increment
          end
        end
      end
    end.each(&:join)
  end

  def self.recieve_pages_parallel
    mutex = Mutex.new
    pages = []

    ENV["THREADS_COUNT"].to_i.times.map do
      Thread.new(config.components, pages) do |components, pages|
        while component = mutex.synchronize { components.pop }
          new_pages = component.new(config.notion_client).get_pages

          mutex.synchronize do
            pages.concat new_pages
          end
        end
      end
    end.each(&:join)

    pages
  end
end
