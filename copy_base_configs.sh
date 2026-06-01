echo "Copying base configuration files (lightdm, journald, systemd-boot and systemd-boot hook) to their respective locations..."
sudo cp .config/journald.conf /etc/systemd/journald.conf
sudo cp .config/lightdm.conf /etc/lightdm/lightdm.conf
sudo cp .config/reflector.conf /etc/xdg/reflector/reflector.conf
# systemd-boot files are located in esp, which is usually mounted at /boot, so we are copying the files there
sudo cp .config/systemd-boot/loader.conf /boot/loader/loader.conf
sudo cp .config/systemd-boot/entries/arch.conf /boot/loader/entries/arch.conf 
sudo cp .config/systemd-boot/entries/arch-fallback.conf /boot/loader/entries/arch-fallback.conf
sudo cp .config/systemd-boot/95-systemd-boot.hook /etc/pacman.d/hooks/95-systemd-boot.hook
echo "Base configuration files copied successfully."