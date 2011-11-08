
define :logstash_input do
  conf_file = "#{node['logstash']['install_path']}/client.conf"
  t = nil
  begin
    t = resources(:template => conf_file)
  rescue Chef::Exceptions::ResourceNotFound
    t = template conf_file do
      source "client.conf.erb"
      owner "nobody"
      group "nobody"
      mode 0644
      backup 0
      
      # Make sure variables is initialised
      variables(:inputs  => node['logstash']['inputs'],
                :filters => node['logstash']['filters'],
                :outputs => node['logstash']['outputs'])
      Chef::Log.info "logstash conf variables set up"
  
      notifies :restart, "service[logstash]"
    end
  end

  input = { :kind => params[:kind], :params => {} }
  params.each do |k,v|
    next if k == :name
    next if k == :kind
    input[:params][k] = v if v != nil
  end
  t.variables[:inputs] << input
  Chef::Log.info "logstash conf variables is: " << t.variables.inspect

end
