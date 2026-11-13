# Homelab

How my machines fit together, how to reach them, and where things are.

## Overview

| Name | What it is | Where | Job |
|---|---|---|---|
| Mac | MacBook Air | with me | daily laptop |
| `ananas` | Synology NAS | home | stores my files |
| `azpc` | PC (Ryzen 5 5600X, 16 GB, RTX 2060 Super) | home, next to the NAS | keeps a backup of the NAS |
| — | PC (Ryzen 5 7600X, 32 GB, RTX 4070) | home | gaming; planned dev machine |

```
Mac ──Tailscale──► ananas (NAS) ──nightly backup──► azpc (T7 drive)
```

## Getting in

All devices are in my Tailscale network, so the same names work at home and on the road.

| Device | How | Address |
|---|---|---|
| NAS | browser | `http://ananas:5000` |
| azpc | terminal | `ssh <my user>@azpc` (works with my Mac's SSH key, no password) |

If a name doesn't work, use the Tailscale IP from the Tailscale app or https://login.tailscale.com/admin/machines.

## azpc (backup PC)

- **System:** Debian 13, desktop logs in automatically (Firefox for email).
- **Drives:**
  - 240 GB SSD: the system
  - Samsung T7 (2 TB, USB, rear port): **the NAS backup**, at `/srv/backup`
  - 1 TB hard drive: spare space, at `/srv/scratch`
- **Users:**
  - my user: log in with SSH key only.
  - a separate backup user: only for the NAS backup. Password is in my password manager. Password login only works from the home network or Tailscale.
- **Runs by itself:** security updates install automatically and the PC restarts at 04:00 if needed. It never goes to sleep, and turns back on after a power cut.
- **Turn it on remotely:** FRITZ!Box → Heimnetz → Netzwerk → azpc → "Computer starten" (or the MyFRITZ!App).
- **Fixed IP:** set in the FRITZ!Box (same for the NAS).

## Backups

| What | From | To | When |
|---|---|---|---|
| NAS folders | NAS (Hyper Backup app) | azpc, T7 drive, folder `ananas` | daily, 03:00 |

- Hyper Backup keeps older versions, so deleted or changed files can be brought back.
- Backup is not encrypted (the data is not sensitive).
- Hyper Backup emails me if a backup fails.

**Restore a file:** NAS → Hyper Backup → the task → clock icon (Backup Explorer) → choose a date → pick the file → "Copy to".

**If the NAS is dead:** install "Hyper Backup Explorer" on any computer, copy the backup from the T7, and open it there.

## Not done yet

- **Off-site copy.** The NAS and azpc are in the same place, so a fire or theft would take both. The important folders (~150 GB) should also go to cloud storage (Hetzner Storage Box or Cloudflare R2), encrypted.
- Clean up the NAS folder (~500 GB), then turn on snapshots on the NAS.
- Set up the 7600X PC as a dev machine.

## Settings worth knowing

- SSH rules on azpc: `/etc/ssh/sshd_config.d/10-local.conf`
- Backup target setup on azpc: `rsyncd.conf` in the backup user's home folder (Hyper Backup "module" `backup` → `/srv/backup`)
- Drive mounts on azpc: `/etc/fstab` (drives are found by their names `backup` and `scratch`)
- Automatic restarts: `/etc/apt/apt.conf.d/52auto-reboot`
