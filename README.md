# STILL UNDER DEVELOPMENT
# DO NOT USE IT!

# AdminOnDemandForMac
Allow a specific directory group to be admin on the device for few minutes.

# Development guidelines

Settings for this app should be provided via mobileconfig. The standard preference domain should contain a list of scenario identified by name.

For each scenario, we've a list of allowed requester and groups that can be elevated for a specific amount of time.

When someone ask to run the scenario, the system must use Authorization Services and Open Directory API to validate that requester is allowed. Then, the elevation must be done by adding target groups to the local admin groups.

No reboot needed.

Each time a group is added to the admin group, it must be tracked in two way:
* a log file for audit purpose
* a tracker file organized as dictionary with group as key and expiration time as value

Each minute the system must check for expiration and remove related groups from the local admin group.

## The XPC service

XPC service can be run as root and in a single shared instance across all local users if provided by a framework located in `/Library/Framework`. This should be a good way to serialize every request and managed them properly.
