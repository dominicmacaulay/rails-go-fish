class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  layout 'application_without_panel'

  def home
  end
end
