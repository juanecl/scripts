import psutil
import requests
import time
import os
import sys
import argparse

# Constants
SLACK_WEBHOOK_URL = os.environ.get("SLACK_WEBHOOK_URL")  # Store webhook URL in environment variable
CPU_THRESHOLD = int(os.environ.get("CPU_THRESHOLD", 80))  # Percentage
DISK_THRESHOLD = int(os.environ.get("DISK_THRESHOLD", 90))  # Percentage
RAM_THRESHOLD = int(os.environ.get("RAM_THRESHOLD", 90))  # Percentage
SWAP_THRESHOLD = int(os.environ.get("SWAP_THRESHOLD", 90))  # Percentage
NET_CONNECTIONS_THRESHOLD = int(os.environ.get("NET_CONNECTIONS_THRESHOLD", 100))  # Number of connections
CHECK_INTERVAL = int(os.environ.get("CHECK_INTERVAL", 5))  # Seconds

class ResourceMonitor:
    """
    A class to monitor system resources (CPU, Disk, RAM, Network I/O, Disk I/O, Temperature, Swap, Active Connections, Running Processes) and send alerts to Slack.
    """

    def __init__(self, slack_webhook_url, cpu_threshold, disk_threshold, ram_threshold, check_interval, swap_threshold, net_connections_threshold, silent_mode=False):
        self.slack_webhook_url = slack_webhook_url
        self.cpu_threshold = cpu_threshold
        self.disk_threshold = disk_threshold
        self.ram_threshold = ram_threshold
        self.swap_threshold = swap_threshold
        self.net_connections_threshold = net_connections_threshold
        self.check_interval = check_interval
        self.silent_mode = silent_mode
        self.prev_net_io = psutil.net_io_counters()
        self.prev_disk_io = psutil.disk_io_counters()

    # CPU
    def get_cpu_usage(self):
        """
        Get the current CPU usage percentage.
        """
        return psutil.cpu_percent(interval=1)

    def get_cpu_temperature(self):
        """
        Get the current CPU temperature.
        """
        try:
            temps = psutil.sensors_temperatures()
            if 'coretemp' in temps:
                return temps['coretemp'][0].current
            elif 'cpu-thermal' in temps:
                return temps['cpu-thermal'][0].current
            else:
                return None
        except AttributeError:
            return None

    def get_running_processes(self):
        """
        Get the number of running processes.
        """
        processes = psutil.pids()
        return len(processes)

    # Disk
    def get_disk_usage(self):
        """
        Get the current disk usage percentage.
        """
        disk_usage = psutil.disk_usage('/')  # Replace '/' with the desired mount point
        return disk_usage.percent

    def get_disk_io(self):
        """
        Get the current disk I/O statistics.
        """
        disk_io = psutil.disk_io_counters()
        read_bytes = disk_io.read_bytes - self.prev_disk_io.read_bytes
        write_bytes = disk_io.write_bytes - self.prev_disk_io.write_bytes
        self.prev_disk_io = disk_io
        return read_bytes, write_bytes

    # RAM
    def get_ram_usage(self):
        """
        Get the current RAM usage percentage.
        """
        ram_usage = psutil.virtual_memory()
        return ram_usage.percent

    def get_swap_usage(self):
        """
        Get the current swap memory usage percentage.
        """
        swap = psutil.swap_memory()
        return swap.percent

    # Network
    def get_network_io(self):
        """
        Get the current network I/O statistics.
        """
        net_io = psutil.net_io_counters()
        bytes_sent = net_io.bytes_sent - self.prev_net_io.bytes_sent
        bytes_recv = net_io.bytes_recv - self.prev_net_io.bytes_recv
        self.prev_net_io = net_io
        return bytes_sent, bytes_recv

    def get_active_connections(self):
        """
        Get the number of active network connections.
        """
        try:
            connections = psutil.net_connections()
            return len(connections)
        except psutil.AccessDenied:
            return "Access Denied"

    # Alerts
    def send_slack_alert(self, message):
        """
        Send an alert message to Slack.
        """
        if not self.slack_webhook_url:
            return

        payload = {"text": message}

        try:
            response = requests.post(self.slack_webhook_url, json=payload)
            response.raise_for_status()  # Raise HTTPError for bad responses (4xx or 5xx)
        except requests.exceptions.RequestException as e:
            pass

    def check_and_alert(self, resource_name, usage, threshold):
        """
        Check the resource usage against the threshold and send an alert if it exceeds the threshold.
        """
        if isinstance(usage, (int, float)) and usage > threshold:
            message = f"CRITICAL: {resource_name} usage is above {threshold}% ({usage}%)"
            self.send_slack_alert(message)


    # Utility
    def human_readable_size(self, size, decimal_places=2):
        """
        Convert a size in bytes to a human-readable format (KB, MB, GB, etc.).
        """
        for unit in ['B', 'KB', 'MB', 'GB', 'TB', 'PB']:
            if size < 1024:
                return f"{size:.{decimal_places}f} {unit}"
            size /= 1024

    # Monitoring
    def monitor_resources(self):
        """
        Monitor CPU, Disk, RAM, Network I/O, Disk I/O, Temperature, Swap, Active Connections, and Running Processes usage and send alerts if any exceed their respective thresholds.
        """
        while True:
            # CPU
            cpu_usage = self.get_cpu_usage()
            cpu_temp = self.get_cpu_temperature()
            running_processes = self.get_running_processes()

            # Disk
            disk_usage = self.get_disk_usage()
            disk_io_read, disk_io_write = self.get_disk_io()

            # RAM
            ram_usage = self.get_ram_usage()
            swap_usage = self.get_swap_usage()

            # Network
            net_io_sent, net_io_recv = self.get_network_io()
            active_connections = self.get_active_connections()

            # Human-readable formats
            net_io_sent_hr = self.human_readable_size(net_io_sent)
            net_io_recv_hr = self.human_readable_size(net_io_recv)
            disk_io_read_hr = self.human_readable_size(disk_io_read)
            disk_io_write_hr = self.human_readable_size(disk_io_write)

            if not self.silent_mode:
                sys.stdout.write("\033[F\033[K")  # Move cursor up one line and clear the line
                sys.stdout.write("\033[F\033[K")  # Move cursor up one line and clear the line
                sys.stdout.write("\033[F\033[K")  # Move cursor up one line and clear the line
                sys.stdout.write("\033[F\033[K")  # Move cursor up one line and clear the line
                sys.stdout.write(f"\rCPU Usage: {cpu_usage}% | CPU Temp: {cpu_temp}°C | Running Processes: {running_processes}\n")
                sys.stdout.write(f"\rDisk Usage: {disk_usage}% | Disk I/O Read: {disk_io_read_hr} | Disk I/O Write: {disk_io_write_hr}\n")
                sys.stdout.write(f"\rRAM Usage: {ram_usage}% | Swap Usage: {swap_usage}%\n")
                sys.stdout.write(f"\rNet I/O Sent: {net_io_sent_hr} | Net I/O Recv: {net_io_recv_hr} | Active Connections: {active_connections}\n")
                sys.stdout.flush()

            self.check_and_alert("CPU Usage", cpu_usage, self.cpu_threshold)
            self.check_and_alert("Disk Usage", disk_usage, self.disk_threshold)
            self.check_and_alert("RAM Usage", ram_usage, self.ram_threshold)
            self.check_and_alert("Swap Usage", swap_usage, self.swap_threshold)
            self.check_and_alert("Active Connections", active_connections, self.net_connections_threshold)

            time.sleep(self.check_interval)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Monitor system resources and send alerts to Slack.")
    parser.add_argument('--silent', action='store_true', help="Run in silent mode (no console output)")
    args = parser.parse_args()

    monitor = ResourceMonitor(
        slack_webhook_url=SLACK_WEBHOOK_URL,
        cpu_threshold=CPU_THRESHOLD,
        disk_threshold=DISK_THRESHOLD,
        ram_threshold=RAM_THRESHOLD,
        swap_threshold=SWAP_THRESHOLD,
        net_connections_threshold=NET_CONNECTIONS_THRESHOLD,
        check_interval=CHECK_INTERVAL,
        silent_mode=args.silent
    )
    monitor.monitor_resources()