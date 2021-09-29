require 'json'
require 'yaml'
require 'byebug'
require 'notion-ruby-client'

def lambda_handler(event:, context:)
  @client = Notion::Client.new(token: 'secret_hPZNXnkkD97Gh8EhKHrFKyz98CtTaFphQuhRa7M8buY')

  set_icons
  set_progress
end

def set_progress
  filter = {
    property: "Folder",
    select: {
      equals: "Проекты"
    }
  }
  project_pages = @client.database_query(id: 'a49914ab5b20401a924e3517572ed6d5', filter: filter).results

  project_pages.each do |page|

    percent = done_pages_count(page.properties["Одношаговые подзадачи"].relation) / page.properties["Одношаговые подзадачи"].relation.count.to_f
    progress = progress(percent)
    properties = {
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

    @client.update_page(id: page.id, properties: properties) if page.properties["Progress"].rich_text.first.text.content != progress
  end
end

def done_pages_count(pages)
  pages.sum do |page|
    return 1 if @client.page(id: page.id).properties["Folder"]["select"].name == "Done"

    0
  end
end

def progress(percent)
  ("🟢" * (percent * 10).to_i).ljust(10, "⚪")
end

def set_icons
  filters_with_icons = YAML.load_file("configuration.yml")

  filters_with_icons.each do |inst|
    pages = @client.database_query(id: 'a49914ab5b20401a924e3517572ed6d5', filter: inst["filter"]).results

    req_pages = pages.select do |page|
      page.icon.to_h != inst["icon"]
    end

    update_pages(req_pages, icon: inst["icon"])
  end
end

def update_pages(pages, **data)
  puts pages

  pages.each do |page|
    @client.update_page(id: page.id, **data)
  end
end
