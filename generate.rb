require 'google/apis/script_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'

CLIENT_SECRETS_PATH = 'client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials', "chart-generator.yaml")
SCOPE = 'https://www.googleapis.com/auth/userinfo.email'
OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

SCRIPT_ID = '1AkEz4gwcK9AEHdmfh8u-oSVCRzfCxeriadsbFIrpdhkcw2mSTjVS7t2M'

CHART_TYPE= { area: 0,
              stacked_area: 1,
              pie: 2,
              vertical_bar: 3,
              horizontal_bar: 4}

# Handles authentication and loading of the API
def authorize
  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts "Open the following URL in the browser and enter the " +
         "resulting code after authorization"
    puts url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code( user_id: user_id, code: code, base_url: OOB_URI)
  end
  credentials
end
# Initialize the API
service = Google::Apis::ScriptV1::ScriptService.new
service.authorization = authorize

request = Google::Apis::ScriptV1::ExecutionRequest.new(
  function: 'generateChart',
  dev_mode: true # always call last version of script
)

begin
  area_data = { 
    data: {
      labels: ['Aug 15','Aug 16','Aug 17','Aug 18','Aug 19','Aug 20','Aug 21','Aug 22','Aug 23','Aug 24','Aug 25'],
      data: [
        [3258050000, 2272040000, 2553360000, 2941710000, 2975820000, 2109770000, 2800890000, 3764240000, 2369820000, 2037750000, 1727970000],
        [1051800000, 967643000, 909494000, 936160000, 860202000, 571947000, 2448970000, 1336400000, 811990000, 697665000, 760329000],
        [133924000, 106436000, 744605000, 3087490000, 3196230000, 1494020000, 1123400000, 1393260000, 501983000, 407177000, 348632000]],
      series: ['BTC', 'ETH', 'BCH']
    },
    type: CHART_TYPE[:area],
    title: '24 hour volume in USD'
  }
  stacked_area_data = {
    data: {
      labels: ['Aug 15','Aug 16','Aug 17','Aug 18','Aug 19','Aug 20','Aug 21','Aug 22','Aug 23','Aug 24','Aug 25'],
      data: [
        [6975.913, 5966.241, 8215.055, 6838.231, 6930.019, 5966.241, 5277.829, 4084.581, 7297.172, 4459.278, 4459.278],
        [84.680, 85.419, 85.593, 85.743, 89.581, 88.118, 89.205, 89.615, 91.496, 90.336, 89.994],
        [647.9409, 484.7455, 376.8641, 376.0942, 729.4209, 1665.6, 2597, 3185.4, 303.1548, 2540.4, 3054.1]],
      series: ['Bitcoin', 'Ethereum', 'Bitcoin Cash']
    },
    type: CHART_TYPE[:stacked_area],
    title: 'Blockchain Hashrate in Petahertz (PHz)'
  }
  vertical_bar_data = {
    data: {
      labels: ['Aug 15','Aug 16','Aug 17','Aug 18','Aug 19','Aug 20','Aug 21','Aug 22','Aug 23','Aug 24','Aug 25'],
      data: [
        [4326.99, 4200.34, 4384.44, 4324.34, 4137.75, 4189.31, 4090.48, 3998.35, 4089.01, 4137.6, 4332.82],
        [299.95, 289.82, 302.81, 301.7, 296.18, 296.64, 300.48, 321.06, 315.27, 317.45, 326.11],
        [298.19, 297.97, 301.02, 458.67, 697.04, 772.42, 723.7, 596.19, 690.96, 670.03, 627.06]],
      series: ['BTC', 'ETH', 'BCH']
    },
    type: CHART_TYPE[:vertical_bar],
    title: 'Opening price per day in USD'
  }
  horizontal_bar_data = {
    data: {
      labels: ['Tezos','Bancor','Status','Tenx','MobileGO','Sonm','Basic Access Token','Civic','Monaco','Decentraland','FunFair'],
      data: [
        [0.65,3.5,0.038,0.98,0.758,0.25,0.03,0.033,3 ,0.03,0.01],
        [0,2.25,0.031309,2.59,0.565479,0.090947,0.25,0.39,8.2 ,0.017,0.033]],
      series: ['Token price on ICO', 'Token price on 1st Oct']
    },
    type: CHART_TYPE[:horizontal_bar],
    title: 'Top 10 ICOs for 2017'
  }
  pie_data = {
    data: {
      labels: ['EtherMine','F2Pool','NanoPool','MiningPoolHub','Private Pool (0x4750e296)','91pool','Private Pool (0x58b3cabd)' ,'ETCPool PL','Private Pool (0xa4aaf1d8)' ,'Fairpool','Private Pool (0x0058890f)','Private Pool (0x982614fe)','Private Pool (0x00ff662d)', 'NinjaPool.jp', 'ZET Tech'],
      data: [1697,1143,1127,855,427,408,120,80,55,48,38,36,35,35,35]
      },
    type: CHART_TYPE[:pie],
    title: 'Ethereum top miners by number of blocks for 26th Aug 2017'
  }
  request.parameters = []
  request.parameters[0] = horizontal_bar_data

  resp = service.run_script(SCRIPT_ID, request)

  if resp.error
    error = resp.error.details[0]

    puts "Script error message: #{error['errorMessage']}"

    if error['scriptStackTraceElements']
      # There may not be a stacktrace if the script didn't start executing.
      puts "Script error stacktrace:"
      error['scriptStackTraceElements'].each do |trace|
        puts "\t#{trace['function']}: #{trace['lineNumber']}"
      end
    end
  else
    if resp.response['result'] == "Invalid data set"
      raise Exception.new "Invalid data set" 
    else
      File.write("chart.png", resp.response['result'].map(&:to_i).pack('C*'))
    end
  end
rescue Google::Apis::ClientError, Exception => e
  puts e
  # The API encountered a problem before the script started executing.
  puts "Error calling API!"
end
