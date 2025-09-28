sudo ausearch -c 'hl2_linux' --raw | audit2allow -M my-hl2linux
sudo semodule -X 300 -i my-hl2linux.pp