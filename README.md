# Enterprise Network \& SIEM Architecture Lab





# Overview

# This repository documents the deployment of a 3-tier enterprise network topology featuring Cisco infrastructure, a centralized Linux Syslog relay, and a Splunk Security Information and Event Management (SIEM) system hosted on a Windows Server Domain Controller.

# 

# This lab was built in a strict, air-gapped PNETLab environment to simulate a high-security corporate network. It focuses heavily on Layer 2/Layer 3 security, secure logging, and overcoming real-world virtualization hurdles.

# 

# Architecture \& Topology

# Core: R1 Cisco IOS Router  - ISP

# Distribution: R2,R3 Cisco IOS Routers 

# Access: R5 Cisco IOS Switch 

# 

# Management Network: VLAN 99.

# 

# Syslog Relay: Ubuntu 22.04 LTS Server (192.168.99.10).

# 

# Identity \& SIEM: Windows Server 2019 (192.168.55.10) acting as the Primary Domain Controller and Splunk Enterprise host.(Also AAA and jumpserver)

# 

#  Key Objectives Achieved

# Network Foundation: Established BGP routing across multiple subnets and verified Layer 3 reachability.

# 

# Linux Log Forwarding: Configured an Ubuntu server to act as a dedicated rsyslog listener on UDP Port 514, catching Cisco IOS events and sorting them into dedicated files.

# 

# Active Directory Deployment: Promoted a Windows Server to a Domain Controller (AD DS and DNS) in a completely isolated environment.

# 

# Enterprise SIEM: Deployed Splunk Enterprise onto the Domain Controller to ingest, parse, and visualize network logs in real-time.

# 

#  Configuration Highlights

# 1\. Cisco Global Logging

# Configured network devices to timestamp logs via NTP and forward them to the Linux relay:

# Plaintext

# service timestamps log datetime msec

# logging host 192.168.99.10

# logging trap debugging







# 2\. Ubuntu rsyslog Configuration

# Opened the UDP listener and applied a routing rule to prevent network logs from cluttering the main system log:

# File: /etc/rsyslog.conf

# 

# Plaintext

# \# Enable UDP Listener

# module(load="imudp")

# input(type="imudp" port="514")

# 

# \# Sort Cisco traffic into a dedicated file

# :fromhost-ip, startswith, "192.168." /var/log/cisco-network.log

# \& stop







# 3\. Windows Splunk Ingestion

# Firewall: Opened inbound UDP Port 514 via wf.msc.

# 

# Splunk Data Input: Created a new UDP 514 listener mapped to the syslog Operating System source type.

# 





# &#x20;Real-World Troubleshooting \& Solutions :

# During deployment, several enterprise-level security protocols and virtualization quirks were identified and resolved.

# 

# Issue 1: Ubuntu Netplan Floppy I/O Error

# Symptom: Running sudo netplan apply triggered blk\_update\_request: I/O error, dev fd0, sector 0 errors.

# Resolution: Blacklisted the unused floppy module in the Linux kernel.

# 

# Bash

# sudo rmmod floppy

# echo "blacklist floppy" | sudo tee /etc/modprobe.d/blacklist-floppy.conf

# sudo update-initramfs -u







# Issue 2: Cisco Port Security err-disable

# Symptom: Connecting the Ubuntu VM caused an immediate interface shutdown.

# Root Cause: The switchport triggered a Port Security violation due to a existing sticky MAC address.

# Resolution: Cleared the secure MAC and reset the port.

# 

# COMMANDS

# interface e1/1

# &#x20;shutdown

# &#x20;no switchport port-security mac-address sticky

# &#x20;no shutdown







# Issue 3: Dynamic ARP Inspection (DAI) Blocking Servers

# Symptom: The Ubuntu server could not reach its gateway. Switch logs showed %SW\_DAI-4-DHCP\_SNOOPING\_DENY.

# Root Cause: Static IP addressing on the server triggered DAI because no DHCP snooping binding existed.

# Resolution: Created a static ARP Access Control List (ACL) to explicitly permit the server's specific IP-to-MAC binding without blindly trusting the entire switchport.

# 

# COMMANDS

# arp access-list SERVER\_ARP\_ACL

# &#x20;permit ip host 192.168.99.20 mac host aaaa.bbbb.cccc

# exit

# ip arp inspection filter SERVER\_ARP\_ACL vlan 99







# Issue 4: Splunk Air-Gapped Installation

# Symptom: The Windows DC was isolated with no NAT to the internet, preventing direct software downloads.

# Resolution: Utilized a "Crash Cart" method—temporarily bridging a Management Cloud node to a spare interface to pull the .msi, then immediately severing the bridge to restore air-gap integrity.

# 

# Issue 5: Splunk Password Hash Corruption on DC

# Symptom: The Splunk web interface rejected credentials post-installation.

# Root Cause: AD DS security policy overrides during the DC promotion phase.

# Resolution: Forced a password reset by stopping the Splunkd service, renaming the passwd file, and seeding new credentials via user-seed.conf.

