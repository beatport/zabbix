def validate_data_type(connection, data_type)
  puts data_type
  raise Chef::Zabbix::InvalidDataTypeError(data_type) unless connection.respond_to?(data_type)
end

def validate_method(data_type, method)
  puts data_type, method
  raise Chef::Zabbix::InvalidApiMethodError(method) unless data_type.respond_to?(method)
end

def validate_parameters(parameters)
  raise InvalidParametersHashError.new(parameters) unless parameters.is_a?(Hash)
end

action :call do

  chef_gem "zabbixapi" do
    action :install
    version "~> 0.5.9"
  end

  require 'zabbixapi'

  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    validate_data_type(connection, new_resource.data_type)
    data_type = connection.send(new_resource.data_type)

    validate_method(data_type, new_resource.method)
    puts "Method valid, sending stuff.."
    puts new_resource.parameters
    data_type.send(new_resource.method, new_resource.parameters)
  end

  new_resource.updated_by_last_action(true)
end
