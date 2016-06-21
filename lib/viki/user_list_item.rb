class Viki::UserListItem < Viki::Core::Base
  use_ssl
  path "/user-lists/:list_id/items"
end
