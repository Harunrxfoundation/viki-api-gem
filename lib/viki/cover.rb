class Viki::Cover < Viki::Core::Base
  cacheable
  cachebustable
  path "/containers/:container_id/covers/:language"
  path "/containers/:container_id/covers"
end
