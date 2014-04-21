class PictureUploader < CoderwallUploader

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  process :auto_orient

  def auto_orient
    manipulate! do |image|
      image.collapse!
      image.auto_orient
      image
    end
  end

end