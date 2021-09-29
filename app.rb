require 'notion-ruby-client'
require 'dotenv/load'
require_relative "components/set_icons"
require_relative "components/set_projects_progress"

def run
  client = Notion::Client.new(token: ENV["SECRET_TOKEN"])

  components.each do |component|
    component.new(client).call
  end
end

def components
  [Components::SetIcons, Components::SetProjectsProgress]
end

