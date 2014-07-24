class AvatarUploader < CoderwallUploader

  process resize_and_pad: [100, 100]

  #TODO migrate each model to it own uploader
  def default_url
    model_name = model.class.name.downcase
    ActionController::Base.helpers.asset_path "#{model_name}-avatar.png"
  end
end
