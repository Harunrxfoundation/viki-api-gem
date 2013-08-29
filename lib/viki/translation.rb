class Viki::Translation < Viki::Core::Base
  LIKE = 'like'
  DISLIKE = 'dislike'
  REPORT = 'report'
  LANGUAGES = 'languages'

  path "/translations"
  path "/translations/:target_subtitle_id/like", name: LIKE
  path "/translations/:target_subtitle_id/dislike", name: DISLIKE
  path "/translations/:subtitle_id/report", name: REPORT
  path "/translations/languages", name: LANGUAGES

  def self.rating(options = {}, &block)
    preference = options.delete(:like) ? LIKE : DISLIKE
    self.create(options.merge(named_path: preference), &block)
  end

  def self.report(options = {}, &block)
    self.create(options.merge(named_path: REPORT), &block)
  end

  def self.languages(options = {}, &block)
    self.fetch(options.merge(named_path: LANGUAGES), &block)
  end
end
