# Rendering charts on server side

Using Google Apps Script to generate chart images
___

## Requrements
  - Google Account
  - Ruby environment (Google App Script can be called from any other)

## Installation

### Google Script Setup
1. Go to my drive
2. NEW -> Google Apps Script (you may need to authorize this 'app' to your Drive)
3. Give a name to project
4. Copy Code.gs to your Code.gs file
5. GO TO on Publish -> Deploy as API executable
6. Describe version
7. Choose access to script
  - Only myself: you will have to authorize Google App with account that owns script to have access to this script
  - Anyone: you can own script with Account 1 and authorize Google that will execute script with any other Google Account
8. Deploy
9. GO TO Resource -> Cloud Platform project
  Google creates cloud project that is connected to your script by default. You can change project by entering project number in Change Project section
10. GO TO Cloud platform project connected to script
11. GO TO APIs & service -> Library -> Find "Google Apps Script Execution API" and enable it
12. GO TO APIs & service -> Credentials -> 
13. Create Credentials -> OAuth client ID -> Choose Other -> Create
14. Download json of that credentials
15. Rename json file to clients-secret.json and move it to same folder where is located ruby file



### Ruby (Script can be used with any language that can handle HTTP requests)
1. gem install google-api-client
2. Download file charts-generator.rb
3. Change SCRIPT_ID, line 12 (Can be found in Google Apps Script file, File -> Project properties)

## Usage
  Run ruby charts-generator.rb

<img id="altcoin_prices_combined_0" src="https://cdn.patricktriest.com/blog/images/posts/crypto-markets/plot-images/altcoin_prices_combined.png" alt="Combined Altcoin Prices">

## Limitations
  Google Apps Script limitation - 6 min duration
  Script Execution API executions per 100 seconds up to 1,500 (editable)  
  Script Execution API executions per day unlimited (editable)


Feel free to fork this repo! Have fun!

To see more capabilities of Google Apps Script check <a href="https://developers.google.com/apps-script?ref=mal3ta" target="_blank">this link </a>

To see more about Google Charts check <a href="https://developers.google.com/chart/interactive/docs/gallery?ref=mal3ta" target="_blank">this link </a>
