require "ruby-progressbar"
require "byebug"
module Components
  class BaseComponent
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def call
      @progressbar = ProgressBar.create(title: self.class)

      update_pages(pages_with_properties_for_update)
    end

    private

    def pages_with_properties_for_update
      raise NotImplementedError
    end

    def update_pages(pages_with_properties)
      @progressbar.total = pages_with_properties.size

      pages_with_properties.each do |page_with_properties|
        @progressbar.increment
        sleep 0.01

        client.update_page(id: page_with_properties[:page].id, **page_with_properties[:new_properties])
      end
    end
  end
end
