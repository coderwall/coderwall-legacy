module ErrorHelper
  def protips_list(type, count)
    p = Protip.method(type).call.first(count)
  end
end
