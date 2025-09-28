echo "Removing existing driver"
sudo dnf -y remove xorg-x11-drv-nvidia\*
echo "Installing NVIDIA GPU driver"
sudo dnf config-manager --set-enabled rpmfusion-nonfree-nvidia-driver
sudo dnf -y install akmod-nvidia xorg-x11-drv-nvidia-cuda
echo "Forcing kmod to be built"
sudo akmods --force
echo "NVIDIA driver installed"
# force rebuild of initamfs
#sudo dracut --force
# echo "Copying nvidia config to use just external monitor"
# sudo cp nvidia.conf /etc/X11/xorg.conf.d/nvidia.conf
echo "System will restart in 60 seconds"
sudo shutdown -r