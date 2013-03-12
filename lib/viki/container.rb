module Viki
  class Container < Viki::Core::Base
    path 'v4/containers.json'
    path 'v4/containers/:recommended_for/recommendations.json'
    path 'v4/containers/:people_for/people.json'

    def self.popular(options = {}, &block)
      self.fetch(options.merge(sort: 'views_recent'), &block)
    end

    def self.trending(options = {}, &block)
      self.fetch(options.merge(sort: 'trending'), &block)
    end

    def self.recommendations(container_id, options = {}, &block)
      self.fetch(options.merge(recommended_for: container_id), &block)
    end

    def self.people(container_id, options = {}, &block)
      self.fetch(options.merge(people_for: container_id), &block)
    end
  end
end
