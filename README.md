# Real-Time SSH IP Auto-Ban Script

This script monitors active SSH connections and **automatically bans IPs** that are not associated with trusted users. It's ideal for **servers under brute-force attacks** or **shared environments**.

## Features

* Monitors SSH connections on port 22
* Whitelists only specific users (e.g., `user`)
* Bans unknown or unauthorized SSH IPs in real time
* Prevents banning your own IP if using `sudo su` (tracks login user via `who`)
* Uses `iptables` to drop malicious IPs

## ⚙️ Usage

1. **Edit the script** to list your allowed SSH users:

   ```bash
   ALLOWED_USERS=("your_username")
   ```

2. **Run as root**

   ```bash
   sudo bash autoban.sh
   ```

3. View banned IPs in:

   ```
   /tmp/banned_netstat_ips.txt
   ```

## Requirements

* `bash`
* `netstat` (from `net-tools`)
* `iptables`
* `who` command available (standard on most Linux systems)

##  Warning

* Banned IPs are not persistent across reboots.
* Use with caution in shared or containerized environments.
* To persist bans, consider integrating with `iptables-persistent` or `nftables`.
