# aws-db-health-check

Quick test to push out a db and health check the instance. 

## Health Check

`check.py` is a long running task to listen for critical (instance deletion) failure events.

These particular events do not seem common for real world use cases, but are useful for testing.

More useful tests would include checking for instance status, and other health checks. The more important db failure events would be things like disk space, and other resource exhaustion, also developer/logic errors.

## Usage

WARNING: This will create resources in your AWS account.

NOTE: Creating the db instance can take a few minutes.

### Build infra

```bash
cd infra
terraform init

terraform apply
```

### View outputs

This will show the db instance endpoint and the db credentials.

```bash
terraform output
```

### Run health check

```bash
python check.py
```

## Extra

`connect.sh` is a helper script to connect to the db instance. It automatically grabs the terraform output and connects to the db.

```bash
./connect.sh
```