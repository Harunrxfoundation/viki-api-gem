class Viki::Activity < Viki::Core::Base
  cacheable

  DELETE = 'delete_activity'

  path "/activities"
  path "/users/:user_id/activities"
  path "/users/:user_id/activities", name: DELETE

  def self.delete_activity(user_id, body, &block)
    self.destroy({user_id: user_id}.merge(named_path: DELETE), body, &block)
  end
end
