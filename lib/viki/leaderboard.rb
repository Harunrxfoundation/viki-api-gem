class Viki::Leaderboard < Viki::Core::Base
  cacheable
  path "/leaderboards/:type"
end
