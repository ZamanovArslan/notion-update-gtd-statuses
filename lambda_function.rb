require 'json'
require 'notion-ruby-client'

def lambda_handler(event:, context:)
  @client = Notion::Client.new(token: 'secret_hPZNXnkkD97Gh8EhKHrFKyz98CtTaFphQuhRa7M8buY')

  filters_with_icons = [
    # FilterWithIcon.new({
    #   "or": [
    #     {
    #       "property": "Folder",
    #       "select": {
    #         "equals": "Next"
    #       }
    #     }
    #   ]
    # }, {
    #   "type": "emoji",
    #   "emoji": "⏹️"
    # }),
    # FilterWithIcon.new({
    #   "or": [
    #     {
    #       "property": "Folder",
    #       "select": {
    #         "equals": "Ожидание"
    #       }
    #     }
    #   ]
    # }, {
    #   "type": "emoji",
    #   "emoji": "⏲️"
    # }),
    FilterWithIcon.new({
      "or": [
        {
          "property": "Folder",
          "select": {
            "equals": "Done"
          }
        }
      ]
    }, {
      "type": "emoji",
      "emoji": "✅"
    })
  ]

  filters_with_icons.each do |inst|
    pages = @client.database_query(id: 'a49914ab5b20401a924e3517572ed6d5', filter: inst.filters).results

    update_pages(pages, icon: inst.icon)
  end
end

def update_pages(pages, **data)
  pages.each do |page|
    @client.update_page(id: page.id, **data)
  end
end

FilterWithIcon = Struct.new(:filters, :icon)
