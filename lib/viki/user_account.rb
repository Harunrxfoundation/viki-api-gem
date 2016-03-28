class Viki::UserAccount < Viki::Core::Base
  DEFAULT_CARD = 'default_card'
  UPDATE_CARD = 'update_card'

  path '/users/:user_id/account', api_version: 'v5'
  path '/users/:user_id/account/default_card', api_version: 'v5', name: DEFAULT_CARD
  path '/users/:user_id/account/update_card', api_version: 'v5', name: UPDATE_CARD

  def self.default_card(options={})
    Viki::UserAccount.fetch_sync(options.merge(named_path: DEFAULT_CARD))
  end

  def self.update_card(options={})
    Viki::UserAccount.update_sync(options.merge(named_path: UPDATE_CARD))
  end
end
