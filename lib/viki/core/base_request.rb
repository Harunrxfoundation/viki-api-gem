module Viki::Core
  class BaseRequest
    attr_reader :url, :body, :addon_headers, :cacheable
    JSON_FORMAT = "json"

    def initialize(url, body = nil, headers = {}, format=JSON_FORMAT, cache = {}, cachebustable = {})
      @cacheable = cache
      @url = url.to_s
      @format = format
      @body = body ? Oj.dump(body, mode: :compat) : nil
      @addon_headers = headers
      @cachebustable = cachebustable
    end

    def queue(&block)
      request.tap do |req|
        req.on_complete do |res|
          headers = default_headers
          log @url,res,headers
          if is_error?(res)
            if res.timed_out?
              error = Viki::Core::TimeoutErrorResponse.new(@url)
              Viki.reset_hydra
            else
              error = Viki::Core::ErrorResponse.new(res.body, res.code, @url)
            end

            Viki.logger.error(error.to_s)
            log_json(error.to_json)
            raise error if error.invalid_token?
            on_complete error, nil, nil, &block
          else
            begin
              error = nil
              body = @format == JSON_FORMAT ? Oj.load(res.body, mode: :compat, symbol_keys: false) : res.body
            rescue => e
              Viki.logger.error "#{e}. Body #{res.body.to_s} Object: #{self}"
              error = Viki::Core::ErrorResponse.new(res.body, 0, @url)
            ensure
              on_complete error, body, res.headers, &block
            end
          end
        end

        Viki.hydra.queue(req)
      end
    end

    def default_headers(params_hash = {})
      params_hash.merge!(@addon_headers)
      params_hash.tap do |headers|
        headers['User-Agent'] = 'viki'
        headers['Content-Type'] = 'application/json'
        user_ip = Viki.user_ip.call
        headers['X-Forwarded-For'] = user_ip if user_ip
      end
    end

    def log(url, res = nil, request_headers = nil)
      if res != nil
        Viki.logger.info "[API Request] [Responded] [#{Viki.user_ip[]}] #{url} #{res.time}s"
      else
        Viki.logger.info "[API Request] [Cacheable] [#{Viki.user_ip[]}] #{url}"
      end
    end

    def log_json(msg)
    end

    # This helper method facilitates a common cache prefix to be used between
    # subclasses of BaseRequest and a parsed url object of type Addressable::URI
    #
    # Yield a set of the following :
    #  - cache key prefix
    #  - created parsed url under the type Addressable::URI
    def cache_path_components(url)
      parsed_url = Addressable::URI.parse(url)
      cache_key = parsed_url.path
      ["#{Viki.cache_ns}.#{cache_key}", parsed_url]
    end

    def cache_bust
      cache_path_prefix = cache_path_components(@cachebustable.delete(:path))[0]
      bustable_keys = Viki.cache.keys("#{cache_path_prefix}*")
      Viki.cache.del(*bustable_keys) unless bustable_keys.empty?
    end

    # Instead of using attr_reader, use a method so that alias has a '?'
    def cachebustable?
      Viki.cache && @cachebustable.key?(:path)
    end

    private

    def is_error?(response)
      !response.success?
    end
  end
end
