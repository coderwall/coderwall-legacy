class TeamUploader < CoderwallUploader

  process resize_and_pad: [100, 100]

  def store_dir
    "/uploads/team/avatar/#{model.mongo_id || model.id}"
  end

  def default_url
    ActionController::Base.helpers.asset_path 'team-avatar.png'
  end
end
