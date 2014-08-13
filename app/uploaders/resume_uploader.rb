class ResumeUploader < CoderwallUploader

  def extension_white_list
    %w(pdf doc docx jpg jpeg gif png)
  end

end
