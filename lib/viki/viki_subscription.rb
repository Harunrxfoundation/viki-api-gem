class Viki::VikiSubscription < Viki::Core::Base
  APPLIED_COUPONS = 'applied_coupons'
  GIFT_CARD = 'gift_card'
  PERIODS = 'periods'

  path '/viki_subscriptions', api_version: 'v5'
  path '/viki_subscriptions/:viki_subscription_id/applied_coupons', api_version: 'v5', name: APPLIED_COUPONS
  path '/viki_subscriptions/:viki_subscription_id/gift_card', api_version: 'v5', name: GIFT_CARD
  path '/viki_subscriptions/:viki_subscription_id/periods', api_version: 'v5', name: PERIODS

  def self.applied_coupons(options={})
    self.fetch_sync(options.merge(named_path: APPLIED_COUPONS))
  end

  def self.gift_card(options={})
    self.fetch_sync(options.merge(named_path: GIFT_CARD))
  end

  def self.periods(options={})
    self.fetch_sync(options.merge(named_path: PERIODS))
  end
end
