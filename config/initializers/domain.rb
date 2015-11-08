class << Rails.application
    def domain
      ENV["DOCKER"] ? 'docker-links.com' : 'example.com'
    end

    def name
      ENV["DOCKER"] ? 'Docker links' : 'Example news'
    end
  end

Rails.application.routes.default_url_options[:host] = Rails.application.domain
