class Viki::VikiCoupon < Viki::Core::Base
  APPLIED_COUPONS = 'applied_coupons'

  path '/viki_coupons', api_version: 'v5'
  path '/viki_coupons/:viki_coupon_id/applied_coupons', api_version: 'v5', name: APPLIED_COUPONS
  path '/viki_coupons/coupon_codes/:viki_coupon_code', api_version: 'v5'

  def self.applied_coupons(options={})
    self.fetch_sync(options.merge(named_path: APPLIED_COUPONS))
  end
end
