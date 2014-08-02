require 'fileutils'
class BannerUploader < CoderwallUploader
  def apply_tilt_shift
    directory = File.dirname(current_path)
    tmpfile = File.join(directory, "tmpfile")
    FileUtils.mv(current_path, tmpfile)
    system "convert #{tmpfile} -sigmoidal-contrast 7x50% \\( +clone -sparse-color Barycentric '0,0 black 0,%h white' -function polynomial 4.5,-4.5,1 \\) -compose Blur -set option:compose:args 15 -composite #{current_path}"
    File.delete(tmpfile)
  end
end
