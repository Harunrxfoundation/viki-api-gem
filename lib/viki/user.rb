class Viki::User < Viki::Core::Base
  use_ssl
  cacheable
  path "/users"
end
