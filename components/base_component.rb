module Components
  class BaseComponent
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def get_pages
      raise NotImplementedError
    end

    def self.name
      self.to_s.split("::").last
    end
  end
end
