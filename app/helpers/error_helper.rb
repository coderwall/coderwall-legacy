module ErrorHelper
  def protips_list(type, count)
    Protip.method(type).call.first(count)
  end
end
