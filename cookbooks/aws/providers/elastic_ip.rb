include Opscode::Aws::Ec2

# Support whyrun
def whyrun_supported?
  true
end

action :associate do
  ip = new_resource.ip || node['aws']['elastic_ip'][new_resource.name]['ip']
  addr = address(ip)

  if addr.nil?
    fail "Elastic IP #{ip} does not exist"
  elsif addr[:instance_id] == instance_id
    Chef::Log.debug("Elastic IP #{ip} is already attached to the instance")
  else
    converge_by("attach Elastic IP #{ip} to the instance") do
      Chef::Log.info("Attaching Elastic IP #{ip} to the instance")
      attach(ip, new_resource.timeout)
      node.set['aws']['elastic_ip'][new_resource.name]['ip'] = ip
      node.save unless Chef::Config[:solo]
    end
  end
end

action :disassociate do
  ip = new_resource.ip || node['aws']['elastic_ip'][new_resource.name]['ip']
  addr = address(ip)

  if addr.nil?
    Chef::Log.debug("Elastic IP #{ip} does not exist, so there is nothing to detach")
  elsif addr[:instance_id] != instance_id
    Chef::Log.debug("Elastic IP #{ip} is already detached from the instance")
  else
    converge_by("detach Elastic IP #{ip} from the instance") do
      Chef::Log.info("Detaching Elastic IP #{ip} from the instance")
      detach(ip, new_resource.timeout)
    end
  end
end

action :allocate do
  current_elastic_ip = node['aws']['elastic_ip'][new_resource.name]['ip']
  if current_elastic_ip
    Chef::Log.info("An Elastic IP was already allocated for #{new_resource.name} #{current_elastic_ip} from the instance")
  else
    converge_by("allocate new Elastic IP for #{new_resource.name}") do
      addr = ec2.allocate_address(domain: new_resource.domain)
      Chef::Log.info("Allocated Elastic IP #{addr[:public_ip]} from the instance")
      node.set['aws']['elastic_ip'][new_resource.name]['ip'] = addr[:public_ip]
      node.save unless Chef::Config[:solo]
    end
  end
end

private

def address(ip)
  ec2.describe_addresses[:addresses].find { |a| a[:public_ip] == ip }
end

def attach(ip, timeout)
  addr = address(ip)
  if addr[:domain] == 'vpc'
    ec2.associate_address(instance_id: instance_id, allocation_id: addr[:allocation_id])
  else
    ec2.associate_address(instance_id: instance_id, public_ip: addr[:public_ip])
  end

  # block until attached
  begin
    Timeout.timeout(timeout) do
      loop do
        addr = address(ip)
        if addr.nil?
          fail 'Elastic IP has been deleted while waiting for attachment'
        elsif addr[:instance_id] == instance_id
          Chef::Log.debug('Elastic IP is attached to this instance')
          break
        else
          Chef::Log.debug("Elastic IP is currently attached to #{addr[:instance_id]}")
        end
        sleep 3
      end
    end
  rescue Timeout::Error
    raise "Timed out waiting for attachment after #{timeout} seconds"
  end
end

def detach(ip, timeout)
  addr = address(ip)
  if ip[:domain] == 'vpc'
    ec2.disassociate_address(allocation_ip: addr[:allocation_id])
  else
    ec2.disassociate_address(public_ip: ip)
  end

  # block until detached
  begin
    Timeout.timeout(timeout) do
      loop do
        addr = address(ip)
        if addr.nil?
          Chef::Log.debug('Elastic IP has been deleted while waiting for detachment')
        elsif addr[:instance_id] != instance_id
          Chef::Log.debug('Elastic IP is detached from this instance')
          break
        else
          Chef::Log.debug('Elastic IP is still attached')
        end
        sleep 3
      end
    end
  rescue Timeout::Error
    raise "Timed out waiting for detachment after #{timeout} seconds"
  end
end
