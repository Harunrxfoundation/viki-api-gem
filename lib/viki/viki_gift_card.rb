class Viki::VikiGiftCard < Viki::Core::Base
  GIFT_CARD_PURCHASE = 'gift_card_purchase'
  GIFT_CARD_REDEMPTION = 'gift_card_redemption'

  path '/viki_gift_cards', api_version: 'v5'
  path '/viki_gift_cards/:gift_code', api_version: 'v5'
  path '/users/:user_id/viki_gift_cards', api_version: 'v5'
  path '/users/:user_id/viki_gift_cards/:gift_code', api_version: 'v5'
  path '/users/:user_id/viki_gift_cards/:gift_code/redeem', api_version: 'v5', name: GIFT_CARD_REDEMPTION

  def self.redeem(options = {})
    self.create_sync(options.merge(named_path: GIFT_CARD_REDEMPTION))
  end
end
