require_relative "notion_update_gtd_statuses"

def run(components)
  unless components.empty?
    NotionUpdateGtdStatuses.config.components.select! do |component|
      components.include? component.name
    end
  end

  NotionUpdateGtdStatuses.run
end
