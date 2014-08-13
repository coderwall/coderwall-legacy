class ResumeUploader < CoderwallUploader

  def extension_white_list
    %w(pdf doc docx odt txt jpg jpeg png)
  end

end
