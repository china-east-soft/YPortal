class Wifi::ActivitiesController < WifiController

  def index
    @activities = terminal_merchant.activities.all
  end

end