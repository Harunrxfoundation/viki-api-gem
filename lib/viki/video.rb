class Viki::Video < Viki::Core::Base
  cacheable
  path "/videos"
  path "/videos/:tags_for/tags"
  path "/containers/:container_id/videos"
  path "/containers/:container_id/videos/:video_id"

  def self.trending(options = {}, &block)
    self.fetch(options.merge(sort: 'trending'), &block)
  end

  def self.tags(video_id, options = {}, &block)
    self.fetch(options.merge(tags_for: video_id), &block)
  end
end
