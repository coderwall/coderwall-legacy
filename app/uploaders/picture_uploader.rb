class PictureUploader < CoderwallUploader

  process :auto_orient

  def auto_orient
    manipulate! do |image|
      image.collapse!
      image.auto_orient
      image
    end
  end

end