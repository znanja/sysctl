if defined?(ChefSpec)
  ChefSpec::Runner.define_runner_method :sysctl_param

  # @example This checks to see if tcp_max_syn_backlog is applied with the value of 12345
  # expect(chef_run).to apply_sysctl_param('net.ipv4.tcp_max_syn_backlog').with(value: 12_345)
  #
  # @param [String] sysctl parameter key
  #
  # @return [ChefSpec::Matchers::ResourceMatcher]
  #
  def apply_sysctl_param(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sysctl_param, :apply, resource_name)
  end

  def remove_sysctl_param(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sysctl_param, :remove, resource_name)
  end
end
