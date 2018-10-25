# To learn more about Custom Resources, see https://docs.chef.io/custom_resources.html
resource_name :supervisor_config

property :supervisor_directory, String, name_property: true
property :socket_file, String, default: '/var/run/supervisor.sock'

property :unix_http_server_chmod, String, default: '700'
property :unix_http_server_chown, String, default: 'root:root'
property :unix_http_server_username, [String, NilClass], default: nil
property :unix_http_server_password, [String, NilClass], default: nil

property :supervisord_log_directory, String, default: '/var/log/supervisor'
property :supervisord_logfile, String, default: lazy { "#{supervisord_log_directory}/supervisord.log" }
property :supervisord_logfile_maxbytes, String, default: '50MB'
property :supervisord_logfile_backups, Integer, default: 10
property :supervisord_loglevel, String, default: 'info'
property :supervisord_pidfile, String, default: '/var/run/supervisord.pid'
property :supervisord_nodaemon, [TrueClass, FalseClass], default: false
property :supervisord_minfds, Integer, default: 1024
property :supervisord_minprocs, Integer, default: 200
property :supervisord_nocleanup, [TrueClass, FalseClass], default: false
property :supervisord_user, [String, NilClass], default: nil
property :supervisord_umask, [String, NilClass], default: nil
property :supervisord_identifier, String, default: 'supervisor'
property :supervisord_strip_ansi, [TrueClass, FalseClass], default: false
property :supervisord_environment, Hash, default: {}

property :inet_port, [String, NilClass], default: '0.0.0.0:9001'
property :inet_username, [String, NilClass], default: nil
property :inet_password, [String, NilClass], default: nil

property :include_files, [String, Array], default: lazy { "#{supervisor_directory}/*.conf" }

action :create do
  supervisor_config_directory = new_resource.supervisor_directory
  supervisor_config_file = "#{supervisor_config_directory}/supervisord.conf"
  with_run_context :root do
    node.run_state['supervisor'] ||= {}
    node.run_state['supervisor']['directory'] = supervisor_config_directory
    node.run_state['supervisor']['config_file'] = supervisor_config_file
  end

  directory supervisor_config_directory do
    owner 'root'
    group 'root'
    mode '755'
    recursive true
  end

  directory new_resource.supervisord_log_directory do
    owner 'root'
    group 'root'
    mode '755'
    recursive true
  end

  template 'supervisord_config_file' do
    path supervisor_config_file
    source 'supervisord.conf.erb'
    owner 'root'
    group 'root'
    mode '644'
    variables(
      config: new_resource
    )
  end
end
