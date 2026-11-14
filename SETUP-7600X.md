# 7600X setup: Windows (NVMe) + Arch (SATA)

- **2 TB NVMe:** the existing Windows, debloated, games only. It is not reinstalled.
- **1 TB SATA SSD:** Arch, dev machine (default boot)

Keep the Arch Installation guide open on the Mac: https://wiki.archlinux.org/title/Installation_guide

Always confirm device names with `lsblk -o NAME,SIZE,MODEL` before running a command. Below, the SATA SSD is `/dev/sda` and the NVMe (Windows) is `/dev/nvme0n1`. **Never write to the NVMe.**

Written from memory and not tested. Check each phase against the Arch Wiki. Likeliest to be outdated: the snapper `/.snapshots` swap, the NVIDIA package names, and the `kms` hook removal.

---

## Phase 1: Arch USB stick

1. Download the Arch ISO: https://archlinux.org/download/
2. Write it to the stick. **This wipes the stick.**
   - **From the Mac:**
     ```bash
     diskutil list                          # find the stick, e.g. /dev/disk4
     diskutil unmountDisk /dev/disk4
     sudo dd if=archlinux.iso of=/dev/rdisk4 bs=4m status=progress
     ```
   - **From Windows:** Rufus (DD image mode), https://rufus.ie
3. Note the Wi-Fi password, in case Ethernet doesn't work.

## Phase 2: Windows prep (on the NVMe)

1. **BitLocker first.** Check whether the drive is encrypted: Settings → Privacy & security → Device encryption, or `manage-bde -status` in an admin terminal.
   - If it is encrypted, **save the recovery key** (https://account.microsoft.com/devices/recoverykey). Then **suspend** BitLocker before changing BIOS settings, or turn device encryption off.
   - Otherwise, turning off Secure Boot will lock you out of Windows until you enter the key.
2. Create a **restore point**: search "Create a restore point" in Start.
3. Debloat:
   - **Chris Titus WinUtil** (https://github.com/ChrisTitusTech/winutil): pick tweaks individually and avoid the aggressive presets.
   - **O&O ShutUp10++** for privacy and telemetry settings.
   - Uninstall unused apps (Settings → Apps).
   - Disable startup apps (Task Manager → Startup).
4. Turn off **Fast Startup**: Control Panel → Power Options → Choose what the power buttons do.
5. Set the hardware clock to UTC (in an admin terminal):
   ```
   reg add "HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /d 1 /t REG_DWORD /f
   ```
6. BIOS:
   - Update it if a newer version exists. This can reset settings, so do it first.
   - **EXPO** on.
   - **Secure Boot** off.
   - **Wake on LAN** on.
7. Boot into Windows once to check it still works.

## Phase 3: Arch on the SATA SSD

Boot the stick from the boot menu (F8/F11/F12).

**Keyboard and network.** Ethernet usually works on its own. For Wi-Fi, use `iwctl`.

```bash
loadkeys de-latin1           # only if you use a German keyboard
ping -c3 archlinux.org
timedatectl set-ntp true
lsblk -o NAME,SIZE,MODEL     # SATA ≈ 1 TB (sdX), NVMe ≈ 2 TB (nvme0n1, has Windows): don't touch it
```

**Partition.** A 1 GiB EFI partition **on the SATA SSD**, and the rest for btrfs. Windows' EFI partition on the NVMe stays untouched.

```bash
sgdisk --zap-all /dev/sda
sgdisk -n1:0:+1G -t1:ef00 -c1:EFI -n2:0:0 -t2:8300 -c2:arch /dev/sda
mkfs.fat -F32 -n EFI /dev/sda1
mkfs.btrfs -L arch /dev/sda2
```

**Create the btrfs subvolumes:**

```bash
mount /dev/sda2 /mnt
for s in @ @home @snapshots @var_log @pkg; do btrfs subvolume create /mnt/$s; done
umount /mnt
```

**Mount everything.** The EFI partition goes at `/efi` and `/boot` stays on btrfs. That way snapshots include the kernel, so you can boot old snapshots safely.

```bash
o=noatime,compress=zstd
mount -o $o,subvol=@ /dev/sda2 /mnt
mkdir -p /mnt/{efi,home,.snapshots,var/log,var/cache/pacman/pkg}
mount -o $o,subvol=@home      /dev/sda2 /mnt/home
mount -o $o,subvol=@snapshots /dev/sda2 /mnt/.snapshots
mount -o $o,subvol=@var_log   /dev/sda2 /mnt/var/log
mount -o $o,subvol=@pkg       /dev/sda2 /mnt/var/cache/pacman/pkg
mount /dev/sda1 /mnt/efi
```

**Install the base system:**

```bash
pacstrap -K /mnt base base-devel linux linux-lts linux-headers linux-lts-headers \
  linux-firmware amd-ucode btrfs-progs grub efibootmgr networkmanager \
  sudo zsh git openssh neovim zram-generator
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```

**Configure it (inside the chroot).** For `<hostname>`, pick a name that fits `ananas` and `azpc`.

```bash
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime && hwclock --systohc
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
echo 'KEYMAP=de-latin1' > /etc/vconsole.conf            # if German keyboard
echo '<hostname>' > /etc/hostname
printf '[zram0]\nzram-size = ram / 2\n' > /etc/systemd/zram-generator.conf

useradd -m -G wheel -s /usr/bin/zsh <you>
passwd <you>
EDITOR=nvim visudo        # uncomment: %wheel ALL=(ALL:ALL) ALL
systemctl enable NetworkManager sshd fstrim.timer

grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
exit
umount -R /mnt
reboot
```

Remove the stick. In the BIOS, put **GRUB (SATA SSD) first** in the boot order. Reach Windows through the boot menu ("Windows Boot Manager"). Boot Windows once to check it is unaffected.

## Phase 4: First boot (logged in as your user)

**Pacman settings.** In `/etc/pacman.conf`, uncomment `Color` and `ParallelDownloads`. Then:

```bash
sudo pacman -Syu
sudo systemctl enable --now paccache.timer
```

**AUR helper (paru):**

```bash
git clone https://aur.archlinux.org/paru-bin.git /tmp/paru && cd /tmp/paru && makepkg -si
```

**Snapshots.** Snapper wants to create `/.snapshots` itself. So unmount yours, let snapper create its config, then swap your subvolume back in:

```bash
sudo pacman -S snapper snap-pac grub-btrfs inotify-tools
sudo umount /.snapshots && sudo rmdir /.snapshots
sudo snapper -c root create-config /
sudo btrfs subvolume delete /.snapshots
sudo mkdir /.snapshots && sudo mount -a && sudo chmod 750 /.snapshots
sudo systemctl enable --now grub-btrfsd snapper-timeline.timer snapper-cleanup.timer
```

**NVIDIA:**

```bash
sudo pacman -S nvidia-open-dkms nvidia-utils
```

Remove `kms` from `HOOKS` in `/etc/mkinitcpio.conf`. This keeps the open-source nouveau driver out of the early boot image, so it can't conflict with NVIDIA. Then:

```bash
sudo mkinitcpio -P
```

**KDE Plasma:**

```bash
sudo pacman -S plasma-meta sddm konsole dolphin ghostty firefox
sudo systemctl enable sddm
sudo reboot
```

You should land in KDE Plasma (Wayland).

## Phase 5: Remote access

**Tailscale.** In the admin console, rename the machine and turn off key expiry.

```bash
sudo pacman -S tailscale
sudo systemctl enable --now tailscaled
sudo tailscale up
```

**SSH key**, from the Mac:

```bash
ssh-copy-id <you>@<hostname>
```

Then on Arch, turn off password logins. Test a fresh login before closing your current session.

```bash
echo 'PasswordAuthentication no' | sudo tee /etc/ssh/sshd_config.d/10-local.conf
sudo systemctl restart sshd
```

**Firewall:**

```bash
sudo pacman -S ufw
sudo ufw default deny incoming
sudo ufw allow in on tailscale0
sudo ufw enable
sudo systemctl enable ufw
```

**Wake-on-LAN:**

```bash
nmcli connection show
sudo nmcli connection modify "<wired-conn>" 802-3-ethernet.wake-on-lan magic
```

Shut down, then test waking it from the FRITZ!Box: Heimnetz → Netzwerk → `<hostname>` → "Computer starten". It should boot into Arch.

## Phase 6: Dev environment

**Prerequisites and Homebrew:**

```bash
sudo pacman -S curl file procps-ng
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

**Dotfiles.** Afterwards, open a new terminal. `zshrc` already loads Linuxbrew.

```bash
brew install chezmoi
chezmoi init --apply --source ~/code/dotfiles jakobtfr/dotfiles
```

**Docker:**

```bash
sudo pacman -S docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

**Claude Code** (it's a macOS-only cask in the Brewfile):

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

## Phase 7: Backups to the NAS

1. On the NAS: Control Panel → File Services → enable **SFTP**. Create a shared folder `restic`.
2. On Arch:
   ```bash
   sudo pacman -S restic
   restic -r sftp:<nasuser>@ananas:/restic/<hostname> init
   ```
   Store the repository password in your password manager.
3. Add a nightly systemd user timer that backs up `~`, excluding `~/.cache`, `node_modules` and `~/.local/share/docker`. Hyper Backup then copies it on to azpc.

## Phase 8: Wrap up

- Add the PC to `HOMELAB.md`: name, access, how to wake it, backup job.
- Dotfiles:
  - Add a Linux branch to the Brewfile (Claude Code, Codex).
  - Un-ignore the Ghostty config on Linux.
  - Add the Linux brew path to the README.

## If something breaks

- **After an update:** reboot, choose an older snapshot under "Arch Linux snapshots" in GRUB, then roll back with `snapper`.
- **Main kernel won't boot:** choose `linux-lts` in GRUB.
- **The PC suddenly boots into Windows after a Windows update:** reset the boot order in the BIOS, or on Arch check it with `efibootmgr`.
- **Windows asks for a BitLocker recovery key:** enter the key you saved in Phase 2.
