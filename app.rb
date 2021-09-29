require_relative "notion_update_gtd_statuses"
require 'byebug'

NotionUpdateGtdStatuses.config.components << Components::SetProjectsProgress

NotionUpdateGtdStatuses.run

