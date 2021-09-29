require "notion-ruby-client"
require "dotenv/load"
require "dry-configurable"
require_relative "components/set_icons"
require_relative "components/set_projects_progress"

class NotionUpdateGtdStatuses
  extend Dry::Configurable

  setting :components, [Components::SetIcons]

  def self.run
    client = Notion::Client.new(token: ENV["SECRET_TOKEN"])

    config.components.each do |component|
      component.new(client).call
    end
  end
end
