require "google/apis/sheets_v4"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"

class SignupData
    OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
    APPLICATION_NAME = "Google Sheets API Ruby Quickstart".freeze
    CREDENTIALS_PATH = "credentials.json".freeze
    TOKEN_PATH = "token.yaml".freeze
    SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY

    def initialize(config)
      @service = Google::Apis::SheetsV4::SheetsService.new
      @service.client_options.application_name = APPLICATION_NAME
      @service.authorization = self.authorize

      @spreadsheet_id = config['sheet_id']
      @range = "A2:J500"
    end

    def name_from_discord(name)
      sheet_data = self.sheet_data

      sheet_data.values.each do |row| 
        discord_name = row[9]
        first_name = row[2]

        if discord_name == name
          return first_name
        end
      end
      nil
    end

    private
    def sheet_data
      @service.get_spreadsheet_values @spreadsheet_id, @range
    end

    def authorize
      client_id = Google::Auth::ClientId.from_file CREDENTIALS_PATH
      token_store = Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
      authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
      user_id = "default"
      credentials = authorizer.get_credentials user_id
      if credentials.nil?
        url = authorizer.get_authorization_url base_url: OOB_URI
        puts "Open the following URL in the browser and enter the " \
            "resulting code after authorization:\n" + url
        code = gets
        credentials = authorizer.get_and_store_credentials_from_code(
          user_id: user_id, code: code, base_url: OOB_URI
        )
      end
      credentials
    end

end

