require "spec_helper"

describe Api::Route do
  before do
    @route_spec = "
<Route id='9864eb9e615f740526e93f6297e29435'
type='route'
name='Nob Hill'
routeCode='240'
sort='402.0'
version='1399939597'
nw_lon='-76.174684'
nw_lat='43.076706'
se_lon='-76.118363'
se_lat='42.995355'
patternids='e639d4acaefafe4f9366a86414acdbbb,9cc48c650ed4780fd35e800033f4bd15,7e3033cb817e63ba4907ef68ae7fc015,231e221554ac34bd8eb2c3b413843c1a,d288741ed5b33571d694ed7c7a3a7ab9,0ce03b6ff6a991fd141290326109071a,8df7ef61e151827c7a3b4e15dd091aba,9dcb0868a4d0143f06dea271320618c1,c7bcf92381fe0adc4f890173c16b16b4,07858a42d513e038a8721aa0e8cf6b73,e4f1b90c71b1f352823f5af54f8bfb84,51803995b1691149595b9f8c4480ed0e,4466a4d0f08c3f4d1004125f14e28fc9'
>
</Route>
"
    @journey_spec = "
    <Route curloc='http://busme-apis.herokuapp.com/masters/50fcc339223520000c000088/apis/1/968f501b3e02890cffa2a1e1b80bc3ca'
id='968f501b3e02890cffa2a1e1b80bc3ca'
type='journey'
dir='Warehouse'
sort='436.0'
routeCode='643'
version='1399940355'
name='Warehouse'
timeless='false'
startOffset='745'
duration='20.0'
distance='15415.938937646108'
time_zone='America/New_York'
locationRefreshRate='10'
nw_lon='-76.15842'
nw_lat='43.049618'
se_lon='-76.131349'
se_lat='43.035447'
patternid='b2d03c4880f6d57b3b4edfa5aa9c9211'
routeid='89abcb460e3a73c5c839e1b99e838996'
>
<Links>
<Link distance='1191.568971761244' average_speed='19.8594828626874' duration='1.0'/>
<Link distance='2628.7647354610676' average_speed='14.604248530339264' duration='3.0'/>
<Link distance='4009.5913295447585' average_speed='13.365304431815861' duration='5.0'/>
<Link distance='2128.859239098445' average_speed='17.740493659153707' duration='2.0'/>
<Link distance='5457.154661780593' average_speed='10.105841966260359' duration='9.0'/>
</Links>
</Route>
    "
    @pattern_spec = "
<Route id='b2d03c4880f6d57b3b4edfa5aa9c9211' type='pattern' version='1' distance='15415.938937646108'><JPs><JP lon='-76.131502' lat='43.037292' time=''/>
<JP lon='-76.131502' lat='43.037292' time=''/>
<JP lon='-76.131502' lat='43.037292' time=''/>
<JP lon='-76.131502' lat='43.037292' time=''/>
<JP lon='-76.131502' lat='43.037292' time=''/>
<JP lon='-76.131502' lat='43.037292' time=''/>
<JP lon='-76.131502' lat='43.037292' time=''/>
<JP lon='-76.131502' lat='43.037292' time=''/>
<JP lon='-76.131502' lat='43.037292' time=''/>
<JP lon='-76.131502' lat='43.037292' time=''/>
<JP lon='-76.131445' lat='43.036725' time=''/>
<JP lon='-76.131408' lat='43.036497' time=''/>
<JP lon='-76.131349' lat='43.036258' time=''/>
<JP lon='-76.131429' lat='43.036219' time=''/>
<JP lon='-76.131606' lat='43.036152' time=''/>
<JP lon='-76.131729' lat='43.036145' time=''/>
<JP lon='-76.131901' lat='43.03618' time=''/>
<JP lon='-76.132534' lat='43.036392' time=''/>
<JP lon='-76.132765' lat='43.036427' time=''/>
<JP lon='-76.133628' lat='43.036321' time=''/>
<JP lon='-76.133848' lat='43.036309' time=''/>
<JP lon='-76.134267' lat='43.036301' time=''/>
<JP lon='-76.134267' lat='43.036301' time=''/>
<JP lon='-76.134267' lat='43.036301' time=''/>
<JP lon='-76.134267' lat='43.036301' time=''/>
<JP lon='-76.134267' lat='43.036301' time=''/>
<JP lon='-76.134267' lat='43.036301' time=''/>
<JP lon='-76.134267' lat='43.036301' time=''/>
<JP lon='-76.134267' lat='43.036301' time=''/>
<JP lon='-76.134267' lat='43.036301' time=''/>
<JP lon='-76.134267' lat='43.036301' time=''/>
<JP lon='-76.134267' lat='43.036301' time=''/>
<JP lon='-76.134267' lat='43.036301' time=''/>
<JP lon='-76.134267' lat='43.036301' time=''/>
<JP lon='-76.134267' lat='43.036301' time=''/>
<JP lon='-76.134267' lat='43.036301' time=''/>
<JP lon='-76.134267' lat='43.036301' time=''/>
<JP lon='-76.134267' lat='43.036301' time=''/>
<JP lon='-76.134267' lat='43.036301' time=''/>
<JP lon='-76.134267' lat='43.036301' time=''/>
<JP lon='-76.134267' lat='43.036301' time=''/>
<JP lon='-76.134401' lat='43.036301' time=''/>
<JP lon='-76.134433' lat='43.036258' time=''/>
<JP lon='-76.134433' lat='43.036203' time=''/>
<JP lon='-76.134449' lat='43.035572' time=''/>
<JP lon='-76.134449' lat='43.035572' time=''/>
<JP lon='-76.134449' lat='43.035572' time=''/>
<JP lon='-76.134449' lat='43.035572' time=''/>
<JP lon='-76.134449' lat='43.035572' time=''/>
<JP lon='-76.134449' lat='43.035447' time=''/>
<JP lon='-76.136686' lat='43.035447' time=''/>
<JP lon='-76.137099' lat='43.035454' time=''/>
<JP lon='-76.137394' lat='43.035494' time=''/>
<JP lon='-76.137663' lat='43.035576' time=''/>
<JP lon='-76.137797' lat='43.035638' time=''/>
<JP lon='-76.137797' lat='43.035638' time=''/>
<JP lon='-76.137797' lat='43.035638' time=''/>
<JP lon='-76.137797' lat='43.035638' time=''/>
<JP lon='-76.137797' lat='43.035638' time=''/>
<JP lon='-76.138006' lat='43.035776' time=''/>
<JP lon='-76.138049' lat='43.035827' time=''/>
<JP lon='-76.13807' lat='43.035909' time=''/>
<JP lon='-76.139245' lat='43.035862' time=''/>
<JP lon='-76.139245' lat='43.035862' time=''/>
<JP lon='-76.139245' lat='43.035862' time=''/>
<JP lon='-76.139245' lat='43.035862' time=''/>
<JP lon='-76.139245' lat='43.035862' time=''/>
<JP lon='-76.140554' lat='43.035807' time=''/>
<JP lon='-76.140554' lat='43.035807' time=''/>
<JP lon='-76.140554' lat='43.035807' time=''/>
<JP lon='-76.140554' lat='43.035807' time=''/>
<JP lon='-76.140554' lat='43.035807' time=''/>
<JP lon='-76.140683' lat='43.037399' time=''/>
<JP lon='-76.140683' lat='43.037399' time=''/>
<JP lon='-76.140683' lat='43.037399' time=''/>
<JP lon='-76.140683' lat='43.037399' time=''/>
<JP lon='-76.140683' lat='43.037399' time=''/>
<JP lon='-76.140683' lat='43.037399' time=''/>
<JP lon='-76.140683' lat='43.037399' time=''/>
<JP lon='-76.140683' lat='43.037399' time=''/>
<JP lon='-76.140683' lat='43.037399' time=''/>
<JP lon='-76.140683' lat='43.037399' time=''/>
<JP lon='-76.140683' lat='43.037399' time=''/>
<JP lon='-76.140683' lat='43.037399' time=''/>
<JP lon='-76.140683' lat='43.037399' time=''/>
<JP lon='-76.140683' lat='43.037399' time=''/>
<JP lon='-76.140683' lat='43.037399' time=''/>
<JP lon='-76.140683' lat='43.037399' time=''/>
<JP lon='-76.140683' lat='43.037399' time=''/>
<JP lon='-76.140683' lat='43.037399' time=''/>
<JP lon='-76.140683' lat='43.037399' time=''/>
<JP lon='-76.140683' lat='43.037399' time=''/>
<JP lon='-76.140688' lat='43.03754' time=''/>
<JP lon='-76.139663' lat='43.037576' time=''/>
<JP lon='-76.139663' lat='43.037576' time=''/>
<JP lon='-76.139663' lat='43.037576' time=''/>
<JP lon='-76.139663' lat='43.037576' time=''/>
<JP lon='-76.139663' lat='43.037576' time=''/>
<JP lon='-76.138419' lat='43.037619' time=''/>
<JP lon='-76.138419' lat='43.037619' time=''/>
<JP lon='-76.138419' lat='43.037619' time=''/>
<JP lon='-76.138419' lat='43.037619' time=''/>
<JP lon='-76.138419' lat='43.037619' time=''/>
<JP lon='-76.13821' lat='43.037627' time=''/>
<JP lon='-76.138231' lat='43.037921' time=''/>
<JP lon='-76.138226' lat='43.038207' time=''/>
<JP lon='-76.138' lat='43.039305' time=''/>
<JP lon='-76.138' lat='43.039305' time=''/>
<JP lon='-76.138' lat='43.039305' time=''/>
<JP lon='-76.138' lat='43.039305' time=''/>
<JP lon='-76.138' lat='43.039305' time=''/>
<JP lon='-76.137856' lat='43.040175' time=''/>
<JP lon='-76.13785' lat='43.040367' time=''/>
<JP lon='-76.13785' lat='43.040367' time=''/>
<JP lon='-76.13785' lat='43.040367' time=''/>
<JP lon='-76.13785' lat='43.040367' time=''/>
<JP lon='-76.13785' lat='43.040367' time=''/>
<JP lon='-76.137807' lat='43.042579' time=''/>
<JP lon='-76.137807' lat='43.042579' time=''/>
<JP lon='-76.137807' lat='43.042579' time=''/>
<JP lon='-76.137807' lat='43.042579' time=''/>
<JP lon='-76.137807' lat='43.042579' time=''/>
<JP lon='-76.137781' lat='43.043935' time=''/>
<JP lon='-76.137781' lat='43.043935' time=''/>
<JP lon='-76.137781' lat='43.043935' time=''/>
<JP lon='-76.137781' lat='43.043935' time=''/>
<JP lon='-76.137781' lat='43.043935' time=''/>
<JP lon='-76.137732' lat='43.045268' time=''/>
<JP lon='-76.137732' lat='43.045268' time=''/>
<JP lon='-76.137732' lat='43.045268' time=''/>
<JP lon='-76.137732' lat='43.045268' time=''/>
<JP lon='-76.137732' lat='43.045268' time=''/>
<JP lon='-76.1377' lat='43.046577' time=''/>
<JP lon='-76.1377' lat='43.046577' time=''/>
<JP lon='-76.1377' lat='43.046577' time=''/>
<JP lon='-76.1377' lat='43.046577' time=''/>
<JP lon='-76.1377' lat='43.046577' time=''/>
<JP lon='-76.1377' lat='43.046577' time=''/>
<JP lon='-76.1377' lat='43.046577' time=''/>
<JP lon='-76.1377' lat='43.046577' time=''/>
<JP lon='-76.1377' lat='43.046608' time=''/>
<JP lon='-76.1377' lat='43.046608' time=''/>
<JP lon='-76.137657' lat='43.046624' time=''/>
<JP lon='-76.137749' lat='43.046608' time=''/>
<JP lon='-76.137748' lat='43.046857' time=''/>
<JP lon='-76.137748' lat='43.046975' time=''/>
<JP lon='-76.137745' lat='43.047099' time=''/>
<JP lon='-76.137736' lat='43.047588' time=''/>
<JP lon='-76.137721' lat='43.04835' time=''/>
<JP lon='-76.137814' lat='43.048335' time=''/>
<JP lon='-76.137721' lat='43.04835' time=''/>
<JP lon='-76.137718' lat='43.048487' time=''/>
<JP lon='-76.139745' lat='43.04851' time=''/>
<JP lon='-76.139745' lat='43.048508' time=''/>
<JP lon='-76.139745' lat='43.04851' time=''/>
<JP lon='-76.139932' lat='43.048512' time=''/>
<JP lon='-76.139906' lat='43.049427' time=''/>
<JP lon='-76.14153' lat='43.049452' time=''/>
<JP lon='-76.141551' lat='43.049434' time=''/>
<JP lon='-76.14153' lat='43.049452' time=''/>
<JP lon='-76.142136' lat='43.049461' time=''/>
<JP lon='-76.142162' lat='43.048566' time=''/>
<JP lon='-76.142298' lat='43.048568' time=''/>
<JP lon='-76.142299' lat='43.048508' time=''/>
<JP lon='-76.142298' lat='43.048568' time=''/>
<JP lon='-76.143896' lat='43.048587' time=''/>
<JP lon='-76.145489' lat='43.048609' time=''/>
<JP lon='-76.145617' lat='43.048611' time=''/>
<JP lon='-76.145756' lat='43.048612' time=''/>
<JP lon='-76.145888' lat='43.04861' time=''/>
<JP lon='-76.1465' lat='43.048615' time=''/>
<JP lon='-76.147191' lat='43.048618' time=''/>
<JP lon='-76.147418' lat='43.048636' time=''/>
<JP lon='-76.147711' lat='43.048653' time=''/>
<JP lon='-76.14818' lat='43.048656' time=''/>
<JP lon='-76.148334' lat='43.048657' time=''/>
<JP lon='-76.149313' lat='43.04866' time=''/>
<JP lon='-76.150174' lat='43.048667' time=''/>
<JP lon='-76.150515' lat='43.048673' time=''/>
<JP lon='-76.150826' lat='43.048678' time=''/>
<JP lon='-76.151326' lat='43.04868' time=''/>
<JP lon='-76.151496' lat='43.048681' time=''/>
<JP lon='-76.152216' lat='43.048684' time=''/>
<JP lon='-76.153113' lat='43.048695' time=''/>
<JP lon='-76.153114' lat='43.048696' time=''/>
<JP lon='-76.153113' lat='43.048695' time=''/>
<JP lon='-76.153567' lat='43.0487' time=''/>
<JP lon='-76.154073' lat='43.048703' time=''/>
<JP lon='-76.15439' lat='43.048706' time=''/>
<JP lon='-76.155525' lat='43.048718' time=''/>
<JP lon='-76.155523' lat='43.04933' time=''/>
<JP lon='-76.155522' lat='43.049618' time=''/>
<JP lon='-76.155856' lat='43.049618' time=''/>
<JP lon='-76.156535' lat='43.049589' time=''/>
<JP lon='-76.156773' lat='43.04958' time=''/>
<JP lon='-76.157236' lat='43.049566' time=''/>
<JP lon='-76.157311' lat='43.049563' time=''/>
<JP lon='-76.157395' lat='43.049561' time=''/>
<JP lon='-76.157431' lat='43.049559' time=''/>
<JP lon='-76.157486' lat='43.049557' time=''/>
<JP lon='-76.157596' lat='43.049551' time=''/>
<JP lon='-76.158178' lat='43.049523' time=''/>
<JP lon='-76.15842' lat='43.049512' time=''/>
<JP lon='-76.158368' lat='43.049352' time=''/>
<JP lon='-76.158278' lat='43.049257' time=''/>
<JP lon='-76.158123' lat='43.049228' time=''/>
<JP lon='-76.157845' lat='43.049248' time=''/>
<JP lon='-76.157838' lat='43.049161' time=''/>
</JPs>
</Route>
"
  end
  it "should initialize route" do
    route = Api::Route.new
    tag = Api::Tag.new(REXML::Document.new(@route_spec).root)
    route.loadParsedXML(tag)
    expect(route.code).to eq("240")
  end

  it "should initialize journey" do
    route = Api::Route.new
    tag = Api::Tag.new(REXML::Document.new(@journey_spec).root)
    route.loadParsedXML(tag)
    expect(route.type).to eq("journey")
    expect(route.getStartTime).to eq(Time.parse("12:25"))
    expect(route.getEndTime).to eq(Time.parse("12:45"))
  end

  class TestJourneyStore
    attr_accessor :journeys
    def initialize; self.journeys = {}; end
    def getPattern(id); journeys[id]; end
  end

  it "journey should push locations" do
    api = Api::BuspassAPI.new("", "Android", "0.0")
    route = Api::Route.new
    tag = Api::Tag.new(REXML::Document.new(@journey_spec).root)
    route.loadParsedXML(tag)
    route.busAPI = api
    pattern = Api::JourneyPattern.new
    tag1 = Api::Tag.new(REXML::Document.new(@pattern_spec).root)
    pattern.loadParsedXML(tag1)
    # Mock Journey Store for the patterns
    route.journeyStore = TestJourneyStore.new
    route.journeyStore.journeys[pattern.id] = pattern
    loc = Api::JourneyLocation.new
    loc.lat = pattern.path.last.latitude
    loc.lon = pattern.path.last.longitude
    loc.timediff = 1 * 60
    loc.dir = 0.0
    loc.distance = pattern.distance
    loc.reported_time = route.getEndTime
    loc.onroute = true
    loc.reported = true
    route.pushCurrentLocation(loc)
    expect(route.lastKnownLocation.latitude).to eq(loc.lat)
    expect(route.lastKnownLocation.longitude).to eq(loc.lon)
    expect(route.reported).to eq(true)
    expect(route.isFinished?).to eq(true)
  end

end