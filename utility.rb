module Utility
  module_function

  def collect_information
    {
      data: read_data,
      messages: read_messages,
      incidents: read_incidents,
      current_incident_data: read_current_incident_data,
    }
  end
  alias refresh_information collect_information

  def read_data
    content = File.read('./data.json')
    data = JSON.parse(content)
  end

  def read_messages
    content = File.read('./messages.json')
    messages = JSON.parse(content)
  end

  def read_incidents
    content = File.read('./incidents.json')
    incidents = JSON.parse(content)
  end

  def read_current_incident_data
    content = File.read('./current_incident_data.json')
    current_incident_data = JSON.parse(content)
  end
end
