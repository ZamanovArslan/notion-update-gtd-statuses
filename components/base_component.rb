module Components
  class BaseComponent
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def call
      raise NotImplementedError
    end

    private

    def update_pages(pages, **data)
      pages.each do |page|
        puts("#{page.properties['Name'].title.first.plain_text} => #{data}")
        client.update_page(id: page.id, **data)
      end
    end
  end
end
