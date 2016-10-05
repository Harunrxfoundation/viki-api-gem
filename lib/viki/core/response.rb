module Viki::Core
  class Response < Struct.new(:error, :value, :fetcher, :raw)
  end
end
