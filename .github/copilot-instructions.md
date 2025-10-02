# Copilot Instructions for shell-roboshop

## Overview
This repository automates the setup and management of the Roboshop application's infrastructure and services using shell scripts. It primarily targets CentOS/RHEL-based systems and AWS environments.

## Architecture & Components
- **catalogue.sh**: Installs Node.js, deploys the catalogue service, sets up systemd, and loads MongoDB schema.
- **mongo.sh**: Installs and configures MongoDB, enables remote access, and manages the MongoDB service.
- **roboshop.sh**: Provisions AWS EC2 instances and updates Route53 DNS records for service endpoints.
- **catalogue.service**: Systemd unit file for the catalogue Node.js service, with MongoDB connection details.
- **mongo.repo**: YUM repository configuration for MongoDB installation.

## Key Patterns & Conventions
- **Logging**: All scripts log to `/var/log/roboshop/<script>.log`. Use the `VALIDATE` function to check command success and log errors.
- **Root Privileges**: Scripts require root access. They exit if not run as root.
- **Service Management**: Systemd is used for service lifecycle (`daemon-reload`, `enable`, `start`, `restart`).
- **Environment Variables**: Service files use explicit environment variables for configuration (e.g., `MONGO_URL`).
- **Remote Schema Loading**: The catalogue service loads its schema into MongoDB using `mongosh` and a local JS file.
- **AWS Integration**: `roboshop.sh` provisions EC2 instances and updates DNS records using AWS CLI. Instance names passed as arguments determine DNS logic.

## Developer Workflows
- **Provisioning**: Run `roboshop.sh <service-names>` to create EC2 instances and configure DNS.
- **Service Setup**: Execute `mongo.sh` and `catalogue.sh` as root to install and configure MongoDB and the catalogue service.
- **Debugging**: Check logs in `/var/log/roboshop/` for troubleshooting. Use the `VALIDATE` function output for error context.
- **Customizing**: Update `catalogue.service` and `mongo.repo` for service-specific configuration or repository changes.

## External Dependencies
- **Node.js**: Installed via DNF, version 20 enabled explicitly.
- **MongoDB**: Installed from a custom YUM repo (`mongo.repo`).
- **AWS CLI**: Required for provisioning and DNS updates in `roboshop.sh`.
- **Artifacts**: Catalogue app code is downloaded from an S3 bucket.

## Example: Adding a New Service
1. Create a `<service>.sh` script following the logging and validation patterns.
2. Add a systemd service file for the new service.
3. Update provisioning logic in `roboshop.sh` if DNS or AWS setup is needed.

## References
- Key files: `catalogue.sh`, `mongo.sh`, `roboshop.sh`, `catalogue.service`, `mongo.repo`
- Logs: `/var/log/roboshop/`
- AWS CLI documentation: https://docs.aws.amazon.com/cli/latest/reference/

---
If any section is unclear or missing details, please specify which workflows, patterns, or files need further documentation.