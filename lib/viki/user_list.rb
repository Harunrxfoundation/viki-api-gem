class Viki::UserList < Viki::Core::Base
  use_ssl
  cacheable
  path "/user-lists"
end
