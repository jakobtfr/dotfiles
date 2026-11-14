# Homelab

How my machines fit together, how to reach them, and where things are.

## Overview

| Name | What it is | Where | Job |
|---|---|---|---|
| Mac | MacBook Air | with me | daily laptop |
| `ananas` | Synology NAS | home | stores my files |
| `azpc` | PC (Ryzen 5 5600X, 16 GB, RTX 2060 Super) | home, next to the NAS | monthly offline backup of the NAS; usually off |
| — | PC (Ryzen 5 7600X, 32 GB, RTX 4070) | home | gaming; planned dev machine |

```
Mac ──Tailscale──► ananas (NAS) ──daily backup────► Backblaze B2 (cloud)
                                 └─monthly backup──► azpc (T7 drive, off otherwise)
```

## Getting in

All devices are in my Tailscale network, so the same names work at home and on the road.

| Device | How | Address |
|---|---|---|
| NAS | browser | `http://ananas:5000` |
| NAS files | file browser | `smb://ananas/homes` (Mac: Finder → Go → Connect to Server; Debian: Files → Other Locations). Log in with the NAS user, domain `WORKGROUP`. |
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
- **Usually switched off.** I turn it on once a month for the offline backup (see below). It stays off after a power cut (BIOS setting).
- **While on:** security updates install automatically, it never goes to sleep, and it restarts at 04:00 if an update needs it.
- **Turn it on remotely:** FRITZ!Box → Heimnetz → Netzwerk → azpc → "Computer starten" (or the MyFRITZ!App).
- **Fixed IP:** set in the FRITZ!Box (same for the NAS).

## Backups

| What | From | To | When |
|---|---|---|---|
| `homes` | NAS (Hyper Backup) | Backblaze B2, EU region, folder `ananas` | daily, 02:00 |
| `homes` | NAS (Hyper Backup) | azpc, T7 drive, folder `ananas` | by hand, once a month |

- Hyper Backup keeps older versions (Smart Recycle, 30), so deleted or changed files can be brought back.
- **B2 backup is encrypted.** Password and key file (`.pem`) are in my password manager. Without them the cloud backup can't be restored.
- B2 keeps deleted files for 30 more days (bucket setting). Billing is set up; it costs about $1 a month.
- In Hyper Backup, B2 is set up as "S3 Storage" with a custom server (the bucket's endpoint).
- The azpc backup is not encrypted. Because azpc is off most of the time, that copy is safe even if the NAS gets hacked.
- Hyper Backup emails me if a backup fails.

**Monthly offline backup:**
1. Turn on azpc: FRITZ!Box → Heimnetz → Netzwerk → azpc → "Computer starten".
2. NAS → Hyper Backup → the azpc task → "Back up now". Wait until it says "Successful".
3. Update azpc: `ssh -t <my user>@azpc 'sudo apt update && sudo apt full-upgrade -y'`
4. Turn it off: `ssh -t <my user>@azpc 'sudo poweroff'`

**Restore a file:** NAS → Hyper Backup → the task → clock icon (Backup Explorer) → choose a date → pick the file → "Copy to".

**If the NAS is dead:** install "Hyper Backup Explorer" on any computer and open the backup from the T7 (copy it over first), or download the B2 backup and open it with the encryption password.

## Not done yet

- Clean up the NAS folder (~500 GB), then turn on snapshots on the NAS.
- Set up the 7600X PC as a dev machine.

## Settings worth knowing

- SSH rules on azpc: `/etc/ssh/sshd_config.d/10-local.conf`
- Backup target setup on azpc: `rsyncd.conf` in the backup user's home folder (Hyper Backup "module" `backup` → `/srv/backup`)
- Drive mounts on azpc: `/etc/fstab` (drives are found by their names `backup` and `scratch`)
- Automatic restarts: `/etc/apt/apt.conf.d/52auto-reboot`
