class AvatarUploader < CoderwallUploader

  process resize_and_pad: [100, 100]

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def default_url
    asset_path "team-avatar.png"
  end
end
