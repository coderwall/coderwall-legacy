v2.6.4 (2015-02-18)
-------------------
- Reverting all chef_gem compile_time edits

v2.6.3 (2015-02-18)
-------------------
- Fixing chef_gem with Chef::Resource::ChefGem.method_defined?(:compile_time)

v2.6.2 (2015-02-18)
-------------------
- Fixing chef_gem for Chef below 12.1.0

v2.6.1 (2015-02-17)
-------------------
- Being explicit about usage of the chef_gem's compile_time property.
- Eliminating future deprecation warnings in Chef 12.1.0.

v2.6.0 (2015-02-10)
-------------------
- Convert to use aws-sdk instead of right_aws

v2.5.0 (2014-10-22)
-------------------
- [#60] Updates to CHANGELOG
- [#85] Lots of testing harness goodness
- [#89] Add a recipe to setup ec2 hints in ohai
- [#74] README and CHANGELOG updates
- [#65] Add a resource for enabling CloudWatch Detailed Monitoring
- [#90] Add tests for aws_instance_monitoring

v2.4.0 (2014-08-07)
-------------------
- #64 - force proxy off for metadata queries

v2.3.0 (2014-07-02)
-------------------
- Added support for provisioning General Purpose (SSD) volumes (gp2)


v2.2.2 (2014-05-19)
-------------------
- [COOK-4655] - Require ec2 gem


v2.2.0 (2014-04-23)
-------------------
- [COOK-4500] Support IAM roles for ELB


v2.1.1 (2014-03-18)
-------------------
- [COOK-4415] disk_existing_raid resource name inconsistency


v2.1.0 (2014-02-25)
-------------------
### Improvement
- **[COOK-4008](https://tickets.opscode.com/browse/COOK-4008)** - Add name property for aws_elastic_ip LWRP


v2.0.0 (2014-02-19)
-------------------

- [COOK-2755] Add allocate action to the elastic ip resource
- [COOK-2829] Expose AWS credentials for ebs_raid LWRP as parameters
- [COOK-2935] 
- [COOK-4213] Use use_inline_resources
- [COOK-3467] Support IAM role
- [COOK-4344] Add support for mounting existing raids and reusing volume
- [COOK-3859] Add VPC support (allocation_id) to AWS elastic_ip LWRPJoseph Smith


v1.0.0
------
### Improvement
- [COOK-2829] - Expose AWS credentials for ebs_raid LWRP as parameters
- Changing attribute defaults begs a major version bump


v0.101.6
--------
### Bug
- **[COOK-3475](https://tickets.opscode.com/browse/COOK-3475)** - Fix an issue where invoking action detach in the `ebs_volume` provider when the volume is already detached resulted in a failure

v0.101.4
--------
### Improvement
- **[COOK-3345](https://tickets.opscode.com/browse/COOK-3345)** - Add `aws_s3_file` LWRP
- **[COOK-3264](https://tickets.opscode.com/browse/COOK-3264)** - Allow specifying of file ownership for `ebs_raid` resource `mount_point`

### Bug
- **[COOK-3308](https://tickets.opscode.com/browse/COOK-3308)** - Ensure mdadm properly allocates the device number

v0.101.2
--------
### Bug

- [COOK-2951]: aws cookbook has foodcritic failures

### Improvement

- [COOK-1471]: aws cookbook should mention the route53 cookbook

v0.101.0
--------
### Bug

- [COOK-1355]: AWS::ElasticIP recipe uses an old RightAWS API to associate an elastic ip address to an EC2 instance
- [COOK-2659]: `volume_compatible_with_resource_definition` fails on valid `snapshot_id` configurations
- [COOK-2670]: AWS cookbook doesn't use `node[:aws][:databag_name]`, etc. in `create_raid_disks`
- [COOK-2693]: exclude AWS reserved tags from tag update
- [COOK-2914]: Foodcritic failures in Cookbooks

### Improvement

- [COOK-2587]: Resource attribute for using most recent snapshot instead of earliest
- [COOK-2605]: "WARN: Missing gem '`right_aws`'" always prints when including 'aws' in metadata

### New Feature

- [COOK-2503]: add EBS raid volumes and provisioned IOPS support for AWS

v0.100.6
--------
- [COOK-2148] - `aws_ebs_volume` attach action saves nil `volume_id` in node

v0.100.4
--------
- Support why-run mode in LWRPs
- [COOK-1836] - make `aws_elastic_lb` idempotent

v0.100.2
--------
- [COOK-1568] - switch to chef_gem resource
- [COOK-1426] - declare default actions for LWRPs

v0.100.0
--------
- [COOK-1221] - convert node attribute accessors to strings
- [COOK-1195] - manipulate AWS resource tags (instances, volumes, snapshots
- [COOK-627] - add aws_elb (elastic load balancer) LWRP

v0.99.1
-------
- [COOK-530] - aws cookbook doesn't save attributes with chef 0.10.RC.0
- [COOK-600] - In AWS Cookbook specifying just the device doesn't work
- [COOK-601] - in aws cookbook :prune action keeps 1 less snapshot than snapshots_to_keep
- [COOK-610] - Create Snapshot action in aws cookbook should allow description attribute
- [COOK-819] - fix documentation bug in aws readme
- [COOK-829] - AWS cookbook does not work with most recent right_aws gem but no version is locked in the recipe
