#!/bin/bash
 
# Define variables
reboot_status=0                   # Initialize the reboot status as 0 (not rebooted)
package_patch=0                   # Initialize the package_patch variable to 0 (packages not updated)
packages_updated=0                # Set the packages updated count to 0
 
# Set the start_date and End_date
# Format: YYYY-MM-DD
start_date="2025-03-01"
end_date="2025-02-31"
 
# Transform dates in seconds
start_date_seconds=$(date -d "$start_date" +%s)
end_date_seconds=$(date -d "$end_date" +%s)
 
# Tranform last reboot time in second
last_reboot=$(who -b | awk '{print $3,$4}')
last_reboot_seconds=$(date -d "$last_reboot" +%s)
 
# Check the last reboot to be in interval of patch
if [ "$start_date_seconds" -le "$last_reboot_seconds" ] && [ "$end_date_seconds" -ge "$last_reboot_seconds" ]; then
    reboot_status=1
fi
 
# Get all update timestamps and store them in an array
update_timestamps=($(rpm -qa --last | awk 'NF{print $3,$4,$6}' | while read month day year; do date -d "$month $day $year" +%s; done))
 
 
# Iterate through the update timestamps
for update_timestamp in "${update_timestamps[@]}"; do
    update_date=$update_timestamp
 
    # Check if the update date is within the specified interval or equal to last_reboot_seconds
    if [ "$update_date" -ge "$start_date_seconds" ] && [ "$update_date" -le "$end_date_seconds" ]; then
        packages_updated=$((packages_updated + 1))
    fi
done
 
# Check the Suse Version
suse_version=$(cat /etc/os-release | grep "PRETTY_NAME" | awk -F= '{print $2}' | sed 's/"//g')
 
if [ "$suse_version" == "SUSE Linux Enterprise Server 12 SP4" ] && [ "$packages_updated" -ge 2 ]; then
    package_patch=1  # Set package_patch to 1 if more than 20 packages are updated
elif [ "$packages_updated" -ge 20 ]; then
    package_patch=1
fi
 
 
date=$(echo $last_reboot | awk '{split($1, arr, /[0-9]+/); print $2"-"arr[1]}')
 
kernel_version=$(uname -r)
suse="SLES"$(awk -F= '/VERSION=/{gsub(/[" ]/, "", $2); print $2}' /etc/os-release)
# Check the possibilities and provide feedback
if [ "$reboot_status" -eq 1 ] && [ "$package_patch" -eq 1 ]; then
        echo "REBOOT=YES  PKGs_NUMBER=$packages_updated  SUSE_version=$suse  KERNEL=$kernel_version  REBOOT_date=$date-$(date | awk '{print $6}')"
elif [ "$reboot_status" -eq 0 ] && [ "$package_patch" -eq 1 ]; then
    echo "REBOOT=NO  PKGs_NUMBER=$packages_updated  SUSE_version=$suse  KERNEL=$kernel_version  REBOOT_date=$date-$(date | awk '{print $6}')"
elif [ "$reboot_status" -eq 1 ] && [ "$package_patch" -eq 0 ]; then
    echo "REBOOT=YES  PKGs_NUMBER=$packages_updated  SUSE_version=$suse  KERNEL=$kernel_version  REBOOT_date=$date-$(date | awk '{print $6}')"
else
    echo "REBOOT=NO  PKGs_NUMBER=$packages_updated  SUSE_version=$suse  KERNEL=$kernel_version  REBOOT_date=$date-$(date | awk '{print $6}')"
fi
 
# Print version and number of packages updated
#echo "Version:  $suse_version"
#echo "Packages Update: $packages_updated"
