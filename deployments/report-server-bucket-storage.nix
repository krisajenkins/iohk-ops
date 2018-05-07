{ IOHKaccessKeyId, accountId, ... }:

{
  # this file will create an S3 bucket, and IAM role with access to that bucket
  # then give the report-server machine access to that role, and mount the bucket within the instance
  report-server = { pkgs, resources, ... }: {
    # nixops can only set this at creation, it will need to be manualy set
    deployment.ec2.instanceProfile = "report-server-logs-s3-wildcard";
    fileSystems."/var/lib/report-server" = {
      # mount unsets PATH when running this
      device = "/run/current-system/sw/bin/s3fs#${resources.s3Buckets.report-server-logs.name}";
      fsType = "fuse";
      options = [ "_netdev" "allow_other" ("iam_role=arn:aws:iam::${toString accountId}:policy/report-server-s3-wildcard") ];
    };
    environment.systemPackages = [ pkgs.s3fs ];
  };
  resources = {
    s3Buckets = {
      # if moved to another region, you must rename the bucket
      report-server-logs = { config, uuid, ... }: {
        region = "eu-central-1";
        accessKeyId = IOHKaccessKeyId;
      };
    };
  };
}
