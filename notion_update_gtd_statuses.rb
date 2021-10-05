require "notion-ruby-client"
require "dotenv/load"
require "dry-configurable"
require_relative "components/set_icons"
require_relative "components/set_projects_progress"
require_relative "lib/updates_optimizer"
require 'byebug'

class NotionUpdateGtdStatuses
  extend Dry::Configurable

  setting :components, [Components::SetIcons]
  setting :notion_client, Notion::Client.new(token: ENV["SECRET_TOKEN"])

  def self.run
    progressbar = ProgressBar.create(title: "Updating pages")

    pages = config.components.sum([]) do |component|
      component.new(config.notion_client).get_pages
    end

    pages = UpdatesOptimizer.new(pages).get_pages

    progressbar.total = pages.size

    pages.each do |page|
      progressbar.increment
      sleep 0.01

      config.notion_client.update_page(id: page.id, **page.new_props)
    end
  end
end
