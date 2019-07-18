BASE_URL = "http://localhost:8888"

class UsersController < ApplicationController
  def index
    auth_response, token, checksum, users_response, @users = nil

    auth_response = get_response(BASE_URL+'/auth')

    case auth_response && auth_response.code
      when 200
        token = auth_response.headers["badsec-authentication-token"]
        checksum = Digest::SHA256.hexdigest "#{token}/users"
        users_response = get_response(BASE_URL+'/users', { 'X-Request-Checksum': checksum })

        case users_response && users_response.code
          when 200
            @users = users_response.parsed_response
          else
            puts "Bad Request"
        end

      else
        puts "Bad Request"
    end
  end

  private

  def get_response(end_point, req_headers = nil)
    begin
      HTTParty.get(end_point, headers: req_headers)

    rescue HTTParty::Error => e
      puts 'HTTParty error occurred'
      puts e.message

    rescue SocketError
      puts 'Network connectivity issue'

    rescue Errno::ECONNREFUSED => e
      puts 'The server is down.'
      puts e.message

    rescue Timeout::Error => e
      puts 'Timeout error occurred.'
      puts e.message

    rescue StandardError
      puts 'standard error occurred'
    end
  end
end
