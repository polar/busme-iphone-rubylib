
class TestBasketListener
  include Platform::JourneyBasket::OnBasketUpdateListener
  include Platform::JourneyBasket::OnJourneyAddedListener
  include Platform::JourneyBasket::OnJourneyRemovedListener
  include Platform::JourneyBasket::ProgressListener
  attr_accessor :routes_added
  attr_accessor :routes_removed
  attr_accessor :basket_updated
  def initialize
    clear
  end
  def clear
    self.routes_added = []
    self.routes_removed = []
    self.basket_updated = false
  end
  def onJourneyAdded(basket, route); routes_added << route; end
  def onJourneyRemoved(basket, route); routes_removed << route; end
  def onUpdateBasket(basket); self.basket_updated = true; end
end