# Automation of IP address renewal

This project uses blacklists from <https://github.com/C24Be/AS_Network_List>  
Tested for servers based on Ubuntu 22.04/24.04

## How to use

1. Download the project
2. Move files:

   ```bash
   mv update-rugov.sh /usr/local/bin/
   mv nftables.rugov.conf /etc/
   ```

3. Grant execution rights

   ```bash
   chmod +x /usr/local/bin/update-rugov.sh
   ```

4. Run script `/usr/local/bin/update-rugov.sh`
5. Check log `less /var/log/rugov_blacklist/blacklist_updater.log`
6. Add to Cron `crontab -e`

   ```text
   30 0 * * * /usr/local/bin/update-rugov.sh > /dev/null 2>&1
   @reboot /usr/local/bin/update-rugov.sh > /dev/null 2>&1
   ```

7. Add to log rotation `vim /etc/logrotate.d/rugov_blacklist`

   ```text
   /var/log/rugov_blacklist/*.log {
       rotate 12
       weekly
       compress
       missingok
   }
   ```

Good luck!
