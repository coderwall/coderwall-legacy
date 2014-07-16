class CoderwallUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include ::CarrierWave::Backgrounder::Delay

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def store_dir
    if Rails.env.development? || Rails.env.test?
      "development/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    else
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end
  end

end