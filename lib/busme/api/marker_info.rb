module Api
  class MarkerInfo
    attr_accessor :id
    attr_accessor :point
    attr_accessor :version
    attr_accessor :radius # feet
    attr_accessor :title
    attr_accessor :description
    attr_accessor :goUrl
    attr_accessor :iconUrl

    attr_accessor :seen
  end

end