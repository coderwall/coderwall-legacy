class HomeController < ApplicationController
  layout 'home4-layout'

  def index
    return redirect_to destination_url, flash: flash if signed_in?
    @entrepreneurs = User.username_in(FEATURED_ENTREPRENURES)
    @designers     = User.username_in(FEATURED_DESIGNERS)
    @developers    = User.username_in(FEATURED_CODERS)
    @teams         = Team.any_in(_id: FEATURED_TEAMS).all
  end

  FEATURED_ENTREPRENURES = %w{
    naveen
    tobi
    mojombo
    anildash
    simonw
    topfunky
    caseorganic
  }

  FEATURED_DESIGNERS = %w{
    amyhoy
    lessallan
    chriscoyier
    kylebragger
    sahil
    csswizardry
    davidkaneda
    sachagreif
  }

  FEATURED_CODERS = %w{
    jeresig
    ginatrapani
    wycats
    unclebob
    ry
    chad
    maccman
    shanselman
  }

  # wifelette
  # yukihiro_matz
  # caseorganic

  FEATURED_TEAMS  = %w{
    4f4bef5e9683e0000d000013
    4f27195a973bf0000400083e
    4f271942973bf000040003b0
    4f27193d973bf0000400029d
    4f271946973bf000040004a1
    4f271948973bf00004000515
    4f271951973bf00004000646
    4f271937973bf00004000196
  }

end
