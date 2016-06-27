class Viki::UserList < Viki::Core::Base
  use_ssl
  cacheable
  path "/user-lists"
  path "/user-lists/:list_id"

  def self.order(options = {}, &block)
    ids = options[:ids]
    patch({list_id: options[:list_id]}, { resources: ids }, &block)
  end

  def self.order_sync(options = {}, &block)
    ids = options[:ids]
    patch_sync({list_id: options[:list_id]}, { resources: ids })
  end
end
