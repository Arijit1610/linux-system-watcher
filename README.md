# Linux Watcher Monitoring System

A lightweight Linux monitoring and alerting system built entirely using Bash scripting and systemd.

This project continuously collects system performance metrics, archives historical data, and sends automated alerts for high resource usage.

---

# Features

## System Monitoring

Collects system performance metrics at configurable intervals:

* CPU usage (`top`)
* Memory usage (`free`)
* Disk utilization (`df`)
* I/O statistics (`iostat`)
* Virtual memory statistics (`vmstat`)

---

## Automated Alerting

### CPU Usage Alert

* Sends email alert when CPU usage exceeds threshold
* Includes top CPU-consuming processes
* Supports recovery notifications
* Uses debounce logic to avoid false alerts

### Memory Usage Alert

* Sends alert when memory usage crosses threshold
* Includes top memory-consuming processes
* Recovery email support included

### Filesystem Usage Alert

* Detects high disk usage
* Sends alert per mount point
* Sends recovery notification when usage returns to normal

---

## Data Archiving

* Automatically compresses old monitoring data
* Removes archived files older than configured retention period
* Reduces storage consumption

---

## Service Management

* Managed using `systemd`
* Supports:

  * start
  * stop
  * restart
  * auto-start on boot

---

# Project Structure

```text
/opt/watcher
├── alert_sender/
│   ├── cpu_alert.sh
│   ├── memory_alert.sh
│   └── fs_alert.sh
│
├── archive/
│   └── archive.sh
│
├── bin/
│   └── start.sh
│
├── collectors/
│   ├── top.sh
│   ├── vmstat.sh
│   ├── iostat.sh
│   ├── free.sh
│   └── df.sh
│
├── config.cfg
├── logs/
└── data/
```

---

# Technologies Used

* Bash Scripting
* Linux System Utilities
* systemd
* Mail utilities
* Process management
* File compression (`tar.gz`)

---

# Installation

## Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/linux-watcher.git
cd linux-watcher
```

---

## Make Scripts Executable

```bash
chmod +x collectors/*.sh
chmod +x archive/*.sh
chmod +x alert_sender/*.sh
chmod +x bin/*.sh
```

---

## Configure Variables

Edit:

```bash
vi /opt/watcher/config.cfg
```

Example configuration:

```bash
INTERVAL=30
RETENTION_HOURS=48

path=/opt/watcher/data
LOG=/opt/watcher/logs
BASE=/opt/watcher

threshold=80
max_occurrence=6

FS_ALERT_THRESHOLD=80
FS_CLEAR_THRESHOLD=75

EMAIL=yourmail@example.com
```

---

# systemd Service Setup

Create service file:

```bash
vi /etc/systemd/system/watcher.service
```

Add:

```ini
[Unit]
Description=Custom Linux Watcher Service
After=network.target

[Service]
Type=simple
ExecStart=/opt/watcher/bin/start.sh
Restart=always
RestartSec=5
User=root

[Install]
WantedBy=multi-user.target
```

Reload systemd:

```bash
systemctl daemon-reload
systemctl enable watcher
systemctl start watcher
```

Check status:

```bash
systemctl status watcher
```

---

# Alert Logic

The alert system uses debounce logic to avoid false alerts caused by temporary spikes.

Example:

* CPU usage must remain above threshold for multiple checks before alert is sent
* Recovery alert is triggered only after usage stabilizes below threshold

---

# Future Improvements

* Web dashboard for graphical monitoring
* FAST API integration
* Database-based metric storage
* Real-time visualization using Python/Flask
  
---

# Learning Outcomes

This project helped in learning:

* Linux process management
* systemd service handling
* SELinux troubleshooting
* Monitoring system design
* Bash scripting
* Alerting logic
* Log management
* Automation concepts

---

# License

This project is open-source and available under the MIT License.
