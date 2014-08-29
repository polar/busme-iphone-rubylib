require "spec_helper"
require "test_platform_api"

describe Platform::JourneyDisplayUtility do
  let (:time_now) {Time.now}
  let (:suGet) {
    fileName = File.join("spec", "test_data", "SUGet.xml");
    TestHttpMessage.new(200, "OK", File.read(fileName))
  }
  let (:api) {
    api = TestPlatformApi.new
    api.http_client.httpClient.mock_answer = suGet

    api.forceGet
    api
  }
  let(:store) { Platform::JourneyStore.new }
  let(:basket) {
    basket = Platform::JourneyBasket.new(api, store)
    basket
  }
  let(:journeyDisplayController) { Platform::JourneyDisplayController.new(api, basket) }
  let(:controller) { Platform::JourneySyncController.new(api,journeyDisplayController )}
  let(:route_id) {Api::NameId.new(["643", "9864eb9e615f740526e93f6297e29435", "R", 1399939597])}
  let(:journey_id) {Api::NameId.new(["643", "968f501b3e02890cffa2a1e1b80bc3ca", "V", "643", 1399940355])}
  let(:journey_id2) {Api::NameId.new(["643", "968f501b3e02890cffa2a1e1b80bc3cb", "V", "643", 1399940355])}
  let(:route340_id) {Api::NameId.new(["340", "933043cc587f21af71c0f4803a0373e2", "R", 1399939635])}
  let(:journey340_id1) {Api::NameId.new(["340", "2d0236dbd2a072bbe7f44d8c93a6d32f", "V", "340", 1399939634])}
  let(:journey340_id2) {Api::NameId.new(["340", "451d7074f1580e1224eeef8dbab8ac36", "V", "340", 1399939634])}
  let(:journey340_id3) {Api::NameId.new(["340", "556e3d48986d2cefbfce3b80abda2695", "V", "340", 1399939628])}
  let(:pattern_id) { "b2d03c4880f6d57b3b4edfa5aa9c9211"}
  let(:httpClient) { api.http_client.httpClient }

  let(:responseData) { "
    <Response>
     <R>#{route_id.name},#{route_id.id},#{route_id.type},#{route_id.version}</R>
     <R>#{route340_id.name},#{route340_id.id},#{route340_id.type},#{route340_id.version}</R>
     <J>#{journey_id.name},#{journey_id.id},#{journey_id.type},#{journey_id.route_id},#{journey_id.version}</J>
     <J>#{journey_id2.name},#{journey_id2.id},#{journey_id2.type},#{journey_id2.route_id},#{journey_id2.version}</J>
     <J>#{journey340_id1.name},#{journey340_id1.id},#{journey340_id1.type},#{journey340_id1.route_id},#{journey340_id1.version}</J>
     <J>#{journey340_id2.name},#{journey340_id2.id},#{journey340_id2.type},#{journey340_id2.route_id},#{journey340_id2.version}</J>
     <J>#{journey340_id3.name},#{journey340_id3.id},#{journey340_id3.type},#{journey340_id3.route_id},#{journey340_id3.version}</J>
    </Response>"
  }
  let(:projection) { Utils::ScreenPathUtils::Projection.new( 14, Integration::Rect.new(0, 0, 300, 500))}

  let(:response) { TestHttpMessage.new(200, "OK", responseData)}

  let(:utility) { class T; include Platform::JourneyDisplayUtility; end; T.new}

  before do
    controller
  end

  it "should hit journey locator and miss journey locator" do
    basket.sync([route_id,journey_id,journey_id2,route340_id, journey340_id1, journey340_id2, journey340_id3], nil, nil)

    pattern = store.getPattern(pattern_id)
    expect(pattern).to_not eq(nil)

    path = pattern.path
    expect(path).to_not eq(nil)

    # We make it simple and just pick a point on the line
    touchGP = path[path.size/2]
    expect(touchGP).to_not eq(nil)

    # Translate the GeoPoint to the screen coordinates from the projection
    touchPoint = projection.toMapPixels(touchGP)

    # This is merely used for the max of width and height
    locatorRect = Integration::Rect.new(0,0,25,25)

    # There is currently no known location associated with the route, so therefore
    # it cannot be hit by a locator that will not be there.
    jd = utility.hitsRouteLocator(journeyDisplayController.getJourneyDisplays, touchPoint, locatorRect, projection)
    expect(jd).to eq(nil)

    # Associate a known location to be the expected point
    journey = journeyDisplayController.journeyDisplayMap[journey_id.id]
    expect(journey.route.journeyPatterns.first.id).to eq(pattern_id)

    path = journey.route.journeyPatterns.first.path
    # find out the distance
    dgps = Platform::GeoPathUtils.whereOnPath(path, touchGP, 60)

    dtouchGP = dgps[0]
    journey.route.lastKnownLocation = dtouchGP.geo_point
    journey.route.lastKnownDistance = dtouchGP.distance

    # This should hit our journey.
    jd = utility.hitsRouteLocator(journeyDisplayController.getJourneyDisplays, touchPoint, locatorRect, projection)
    expect(jd).to eq(journey)

    # We moved the touchPoint 1 more than the locatorRect away, so we should hit it.
    touchPoint.offset(26, 26)
    jd = utility.hitsRouteLocator(journeyDisplayController.getJourneyDisplays, touchPoint, locatorRect, projection)
    expect(jd).to eq(nil)
  end

  it "should with finding a common GeoPoint in patterns it should hitPaths in the projection" do
    basket.sync([route_id,journey_id,journey_id2,route340_id, journey340_id1, journey340_id2, journey340_id3], nil, nil)

    # Just find a common point in most of the patterns
    commonPoints = []
    for pattern in store.patterns.values do
      commonPoints << Set.new(pattern.path)
    end
    points = commonPoints.first
    for set in commonPoints
      ps = set.intersection(points)
      points = ps if !ps.empty?
    end
    expect(points.empty?).to eq(false)

    # Translate the GeoPoint to the screen coordinates from the projection
    touchPoint = projection.toMapPixels(points.first)

    # This is merely used for the max of width and height. Paths are 3 pixels wide.
    touchRect = Integration::Rect.new
    touchRect.offsetTo(touchPoint.x, touchPoint.y)
    touchRect.resizeCenter(5,5)

    jds = utility.hitsPaths(journeyDisplayController.getJourneyDisplays, touchRect, projection)
    # Should have at least one selected, possibly more.
    expect(jds[0].empty?).to eq(false)

    # This should be enough to move away from the route with in the 5 pixel buffer
    touchRect.offset(4, 5)
    jds = utility.hitsPaths(journeyDisplayController.getJourneyDisplays, touchRect, projection)
    # None selected
    expect(jds[0].empty?).to eq(true)
  end

end