class Viki::Thread < Viki::Core::Base
  BULK_CREATE='bulk_create'
  path "/users/:user_id/threads"
  path "/users/:user_id/threads/bulk_create", name: BULK_CREATE

  def self.unread_count(user_id, &block)
    self.fetch(user_id: user_id, type: 'inbox', unread: 'true', only_count: 'true', &block)
  end

  def self.unread_count_sync(user_id)
    self.fetch_sync(user_id: user_id, type: 'inbox', unread: 'true', only_count: 'true')
  end

  def self.bulk_create(options = {}, body = {}, &block)
    self.create(options.merge(named_path: BULK_CREATE), body, &block)
  end
end
