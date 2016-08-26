class Viki::Recaps < Viki::Core::Base
  cacheable
  EDIT = 'update_recap'
  DELETE = 'delete_recap'

  path '/recaps', api_version: 'v4'
  path '/recaps/:recap_id', api_version: 'v4', name: EDIT
  path '/recaps/:recap_id', api_version: 'v4', name: DELETE

  def self.create_recap(body = {}, &block)
    self.create({}, body, &block)
  end

  def self.update_recap(recap_id, body = {}, &block)
    self.patch({ recap_id: recap_id }.merge(named_path: EDIT), body, &block)
  end

  def self.delete_recap(recap_id, &block)
    self.destroy({ recap_id: recap_id }.merge(named_path: DELETE), &block)
  end
end
