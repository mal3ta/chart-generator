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
  dev_mode: true # always call last saved version of script
)

begin
  data = {}
  data['type'] = CHART_TYPE[:area]
  data['data'] = {labels: [DateTime.new(2017,1,1).strftime('%^b %d %y'), DateTime.new(2017,1,2).strftime('%^b %d %y'), DateTime.new(2017,1,3).strftime('%^b %d %y'), DateTime.new(2017,1,4).strftime('%^b %d %y'), DateTime.new(2017,1,5).strftime('%^b %d %y')],
                  data: [[100, 121, 144, 113, 200], [200, 221, 244, 213, 300]],
                  series: ["Podaci", "Podaci 2"]}
  request.parameters = []
  request.parameters[0] = data
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
    File.write("chart.png", resp.response['result'].map(&:to_i).pack('C*'))
  end
rescue Google::Apis::ClientError => e
  puts e
  # The API encountered a problem before the script started executing.
  puts "Error calling API!"
end