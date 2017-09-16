require_relative './routific/location'
require_relative './routific/visit'
require_relative './routific/vehicle'
require_relative './routific/route'
require_relative './routific/way_point'
require_relative './routific/options'
require_relative './routific/job'

require_relative './util'

# Main class of this gem
class Routific
  attr_reader :token, :visits, :fleet, :options

  # Constructor
  # token: Access token for Routific API
  def initialize()
    Routific.validate_token
    @token = Routific.token
    @visits = {}
    @fleet = {}
    @options = {}
  end

  # Sets a visit for the specified location using the specified parameters
  # id: ID of location to visit
  # params: parameters for this visit
  def setVisit(id, params={})
    visits[id] = RoutificApi::Visit.new(id, params)
  end

  # Sets a vehicle with the specified ID and parameters
  # id: vehicle ID
  # params: parameters for this vehicle
  def setVehicle(id, params)
    fleet[id] = RoutificApi::Vehicle.new(id, params)
  end

  # Sets options with the specified params
  # params: parameters for these options
  def setOptions(params)
    @options = RoutificApi::Options.new(params)
  end

  # Returns the route using the previously provided visits and fleet information
  def getRoute
    data = {
      visits: visits,
      fleet: fleet
    }

    data[:options] = options if options
    result = Util.send_request("POST", "vrp", Routific.token, data)
    RoutificApi::Route.parse(result)
  end

  def get_route_async
    data = {
      visits: visits,
      fleet: fleet
    }

    data[:options] = options if options
    result = Util.send_request("POST", "vrp-long", Routific.token, data)
    RoutificApi::Job.new(result["job_id"], data)
  end

  class << self
    # Sets the default access token to use
    def setToken(token)
      @@token = token
      validate_token
      @@token = Util.prefix_token(@@token)
    end

    def token
      @@token
    end

    def validate_token
      raise ArgumentError, "access token must be set" if token.nil?
    end

  end
end
