# Upgrading Notes

This document captures required refactoring on your part when upgrading to a module version that contains breaking changes.

## Upgrading to v1.0.0

Initial release of the module. These changes are based on the last tag version (`v0.16.5`)

operating_system_family

### Key Changes

Mainly security related changes and some minor refactoring.

#### Variables

The following variables have been modified:

- `load_balancer_deletion_protection` is now `true` by default.
- `log_retention_days` is now configurable and the default value is updated from 30 to 365 days.
- `ssl_policy` is now `ELBSecurityPolicy-TLS13-1-2-2021-06` by default.
