def load_current_resource
  new_resource.key new_resource.name unless new_resource.key
end

action :apply do
  key_path = new_resource.key.split('.')
  sys_attrs = Mash.new(node.default['sysctl']['params'].to_hash)
  location = key_path.slice(0, key_path.size - 1).reduce(sys_attrs) do |m, o|
    m[o] ||= {}
    m[o]
  end
  unless location[key_path.last] == new_resource.value
    location[key_path.last] = new_resource.value
    if ::File.exists?("/proc/sys/#{new_resource.key}")
      STDOUT.puts "file exists: /proc/sys/#{new_resource.key}"
      execute "sysctl[#{new_resource.key}]" do
        command "sysctl -w \"#{new_resource.key}=#{new_resource.value}\""
        not_if do
          cparam = Mixlib::ShellOut.new("sysctl -n #{new_resource.key}").run_command
          cparam.stdout.strip == new_resource.value.to_s
        end
      end
      node.default['sysctl']['params'] = sys_attrs
    else
      STDOUT.puts "file doesn't exist: /proc/sys/#{new_resource.key}"
      log "unknown sysctl key: #{new_resource.key}" do
        level :warn
      end
    end
    new_resource.updated_by_last_action(true)
  end
end

action :remove do
  key_path = new_resource.key.split('.')
  sys_attrs = Mash.new(node.default['sysctl']['params'].to_hash)
  location = key_path.slice(0, key_path.size - 1).reduce(sys_attrs) do |m, o|
    m.nil? ? nil : m[o]
  end
  if location && location[key_path.last]
    location.delete(key_path.last)
    if location.empty?
      key_path.size.times do |i|
        int_key = key_path.size - i - 1
        l = key_path.slice(0, int_key).reduce(node['sysctl']['params']) do |m, o|
          m.nil? ? nil : m[o]
        end
        if l && l[key_path[int_key]] && l[key_path[int_key]].empty?
          l.delete(key_path[int_key])
        end
      end
    end
    node.default['sysctl']['params'] = sys_attrs
    new_resource.updated_by_last_action(true)
  end
end
