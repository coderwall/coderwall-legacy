class MosaicController < ApplicationController
  def teams
    if Rails.env.development?
      @teams = Team.limit(400)
    else
      @teams = Team.top(400)
    end
  end

  def users
    @users = [User.username_in(FEATURED) + User.top(400)].flatten.uniq
  end

  FEATURED = %w(
    naveen
    tobi
    mojombo
    anildash
    simonw
    topfunky
    caseorganic
    amyhoy
    lessallan
    chriscoyier
    kylebragger
    sahil
    csswizardry
    davidkaneda
    sachagreif
    jeresig
    ginatrapani
    wycats
    unclebob
    ry
    chad
    maccman
    shanselman
  )
end
