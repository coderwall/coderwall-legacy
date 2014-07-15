class BannerUploader < CoderwallUploader
  # process :apply_tilt_shift
  # process :resize_to_fill => [500, 375]
  # process :resize_to_fit => [500, 375]

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def apply_tilt_shift
    directory = File.dirname(current_path)
    tmpfile = File.join(directory, 'tmpfile')
    # record_event('uploading bg image')
    # Resque.enqueue(ProcessImage, :background_image, )
    File.send(:move, current_path, tmpfile)
    system "convert #{tmpfile} -sigmoidal-contrast 7x50% \\( +clone -sparse-color Barycentric '0,0 black 0,%h white' -function polynomial 4.5,-4.5,1 \\) -compose Blur -set option:compose:args 15 -composite #{current_path}"
    File.delete(tmpfile)
  end
end
