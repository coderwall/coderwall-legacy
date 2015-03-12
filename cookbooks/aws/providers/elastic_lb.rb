include Opscode::Aws::Elb

action :register do
  converge_by("add the node #{new_resource.name} to ELB") do
    target_lb = elb.describe_load_balancers[:load_balancer_descriptions].find { |lb| lb[:load_balancer_name] == new_resource.name }
    unless target_lb[:instances].include?(instance_id)
      Chef::Log.info("Adding node to ELB #{new_resource.name}")
      elb.register_instances_with_load_balancer(load_balancer_name: new_resource.name, instances: [{ instance_id: instance_id }])
    else
      Chef::Log.debug("Node #{instance_id} is already present in ELB instances, no action required.")
    end
  end
end

action :deregister do
  converge_by("remove the node #{new_resource.name} from ELB") do
    target_lb = elb.describe_load_balancers[:load_balancer_descriptions].find { |lb| lb[:load_balancer_name] == new_resource.name }
    if target_lb[:instances].include?(instance_id)
      Chef::Log.info("Removing node from ELB #{new_resource.name}")
      elb.deregister_instances_with_load_balancer(load_balancer_name: new_resource.name, instances: [{ instance_id: instance_id }])
    else
      Chef::Log.debug("Node #{instance_id} is not present in ELB instances, no action required.")
    end
  end
end
