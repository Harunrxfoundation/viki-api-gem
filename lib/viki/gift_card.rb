class Viki::GiftCard < Viki::Core::Base
  SEND_EMAIL = 'send_email'
  TYPES = 'types'
  GENERATE = 'generate'

  cacheable
  path "/gift_cards"
  # should put before 'gift_cards/:gift_code'
  path "/gift_cards/types", name: TYPES
  path "/gift_cards/generate", name: GENERATE
  ###
  path "/gift_cards/:gift_code"
  path "/gift_cards/:gift_code/send_email", name: SEND_EMAIL

  def self.send_email(options = {}, body={})
    self.create_sync(options.merge(named_path: SEND_EMAIL), body)
  end

  def self.types(options = {})
    self.fetch_sync(options.merge(named_path: TYPES))
  end

  def self.types(options = {})
    self.fetch_sync(options.merge(named_path: TYPES))
  end

  def self.generate(options = {})
    self.fetch_sync(options.merge(named_path: GENERATE))
  end
end
