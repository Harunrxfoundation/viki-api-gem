module Viki::Core
  class BaseRequest
    attr_reader :url, :body, :headers, :cacheable
    @@addon_headers = {}
    JSON_FORMAT = "json"

    def initialize(url, body = nil, headers = {}, format=JSON_FORMAT, cache = {})
      @cacheable = cache
      @url = url.to_s
      @format = format
      @body = body ? Oj.dump(body, mode: :compat) : nil
      @addon_headers = headers
    end

    def queue(&block)
      request.tap do |req|
        req.on_complete do |res|
          log @url,res
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
      curr_headers = @@addon_headers.merge(params_hash)
      curr_headers.tap do |headers|
        headers['User-Agent'] = 'viki'
        headers['Content-Type'] = 'application/json'
        user_ip = Viki.user_ip.call
        headers['X-Forwarded-For'] = user_ip if user_ip
      end
    end

    def log(url, res = nil)
      if res != nil
        Viki.logger.info "[API Request] [Responded] [#{Viki.user_ip[]}] #{url} #{res.time}s"
      else
        Viki.logger.info "[API Request] [Cacheable] [#{Viki.user_ip[]}] #{url}"
      end
    end

    def log_json(msg)
    end

    private

    def is_error?(response)
      !response.success?
    end
  end
end
