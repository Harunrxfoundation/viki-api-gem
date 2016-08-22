class Viki::Recaps < Viki::Core::Base
  cacheable
  EDIT = 'update_recap'
  DELETE = 'delete_recap'

  path '/videos/:video_id/', api_version: "v4"
  path '/videos/:video_id/recaps/:recap_id', api_version: "v4", name: EDIT
  path '/videos/:video_id/recaps/:recap_id', api_version: "v4", name: DELETE

  def self.create_recap(video_id, body = {}, &block)
    self.create({video_id: video_id}, body, &block)
  end

  def self.update_recap(video_id, recap_id, body = {}, &block)
    self.patch({video_id: video_id, recap_id: recap_id}.merge(named_path: EDIT), body, &block)
  end

  def self.delete_recap(video_id, recap_id, &block)
    self.destroy({video_id: video_id, recap_id: recap_id}.merge(named_path: DELETE), &block)
  end
end
