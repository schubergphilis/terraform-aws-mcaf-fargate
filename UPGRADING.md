# Upgrading Notes

This document captures required refactoring on your part when upgrading to a module version that contains breaking changes.

## Upgrading to v1.0.0

Initial release of the module. These changes are based on the last tag version (`v0.16.5`)

### Behaviour (v1.0.0)

- The `load_balancer_deletion_protection` variable, is now `true` by default.
- The Cloudwatch `log_retention_days` is now configurable and the default value is updated from 30 to 365 days.
