#!/bin/bash

ALLOWED_USERS=("user")
CHECK_INTERVAL=5
BANNED_IPS_FILE="/tmp/banned_netstat_ips.txt"

echo "[*] Monitoring SSH connections (port 22) every $CHECK_INTERVAL seconds..."
touch "$BANNED_IPS_FILE"

while true; do
  declare -A SESSION_MAP
  while read -r user tty ip; do
    clean_ip=$(echo "$ip" | tr -d '()')
    SESSION_MAP["$clean_ip"]="$user"
  done < <(who | awk '{print $1, $2, $5}')

  netstat -tnp 2>/dev/null | grep ':22' | grep ESTABLISHED | while read -r line; do
    ip=$(echo "$line" | awk '{print $5}' | cut -d: -f1)

    grep -q "$ip" "$BANNED_IPS_FILE" && continue

    user="${SESSION_MAP["$ip"]}"

    if [[ -z "$user" ]]; then
      echo "[!] IP $ip has no associated user (could be brute force) — banning"
      iptables -A INPUT -s "$ip" -j DROP
      echo "$ip" >> "$BANNED_IPS_FILE"
      continue
    fi

    if [[ ! " ${ALLOWED_USERS[@]} " =~ " $user " ]]; then
      echo "[!] Unauthorized user '$user' from $ip — banning"
      iptables -A INPUT -s "$ip" -j DROP
      echo "$ip" >> "$BANNED_IPS_FILE"
    else
      echo "[+] Allowed user '$user' from $ip"
    fi
  done

  sleep "$CHECK_INTERVAL"
done
