include Opscode::Aws::Ec2

def whyrun_supported?
  true
end

action :enable do
  if is_monitoring_enabled
    Chef::Log.debug('Monitoring is already enabled for this instance')
  else
    converge_by('enable monitoring for this instance') do
      Chef::Log.info('Enabling monitoring for this instance')
      ec2.monitor_instances(instance_ids: [instance_id])
    end
  end
end

action :disable do
  if is_monitoring_enabled
    converge_by('disable monitoring for this instance') do
      Chef::Log.info('Disabling monitoring for this instance')
      ec2.unmonitor_instances(instance_ids: [instance_id])
    end
  else
    Chef::Log.debug('Monitoring is already disabled for this instance')
  end
end

private

def is_monitoring_enabled
  monitoring_state = ec2.describe_instances(instance_ids: [instance_id])[:reservations][0][:instances][0][:monitoring][:state]
  Chef::Log.info("Current monitoring state for this instance is #{monitoring_state}")
  monitoring_state == 'enabled'
end
