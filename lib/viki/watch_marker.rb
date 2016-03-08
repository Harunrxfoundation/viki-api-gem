class Viki::WatchMarker < Viki::Core::Base
  cacheable
	path '/users/:id/watch_markers', api_version: "v4"
end