class Viki::ChannelManagerApplications < Viki::Core::Base
  MAIN = 'get'
  path '/cm_submissions', api_version: "v4", name: MAIN

  def self.get(options = {}, &block)
    self.fetch(options.merge(named_path: MAIN), &block)
  end

  def self.post(options = {}, body = {}, &block)
    self.create(options.merge(named_path: MAIN), body, &block)
  end
end
