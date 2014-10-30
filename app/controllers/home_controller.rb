class HomeController < ApplicationController
  layout 'home'

  caches_page :index, :swmboxa, :wmboxm, :swmboxapp, :help, :about

  def index
    render :swmboxa
  end

  def swmboxa
  end

  def swmboxm
  end

  def swmboxapp
  end

  def bbs
  end


end
