{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                # disable settings.keyFile if you want to use interactive password entry
                #passwordFile = "/tmp/secret.key"; # Interactive
                settings = {
                  allowDiscards = true;
                  keyFile = "/key/secret.bin";
		  keyFileSize = 4096;
                  #keyFile = "/dev/disk/by-id/usb-Intenso_Micro_Line_24102811710417-0:0";
                };
                #additionalKeyFiles = [ "/tmp/additionalSecret.key" ];
		content = { 
		  type = "zfs";
 		  pool = "zroot"; 
 		};
              };
            };
          };
        };
      };
    };
    zpool = {
	zroot = {
	  type = "zpool";
	  rootFsOptions = {
            checksum = "edonr";
	    acltype = "posixacl";
	    canmount = "off";
	    dnodesize = "auto";
	    normalization = "formD";
	    relatime = "on";
	    compression = "zstd";
	    mountpoint = "none";
	    xattr = "sa";
            "com.sun:auto-snapshot" = "false";
	  };
	  options = {
            ashift = "12";
	    autotrim = "on";
          };
	  datasets = {
            "reserved" = {
	      options = {
                canmount = "off";
                mountpoint = "none";
                reservation = "5G";
              };
	      type = "zfs_fs";
            };
	    "local" = {
	      type = "zfs_fs";
	      options.mountpoint = "none";
	    };
	    "safe" = {
	      type = "zfs_fs";
	      options.mountpoint = "none";
	    };
	    "safe/home" = {
	      type = "zfs_fs";
	      mountpoint = "/home";
	      options."com.sun:auto-snapshot" = "true";
	    };
            "etcssh" = {
	      type = "zfs_fs";
	      options.mountpoint = "legacy";
	      mountpoint = "/etc/ssh";
	      options."com.sun:auto-snapshot" = "false";
              postCreateHook = "zfs snapshot zroot/etcssh@empty";
            };
	    "local/nix" = {
	      type = "zfs_fs";
	      mountpoint = "/nix";
	      options."com.sun:auto-snapshot" = "false";
	    };
	    "safe/persist" = {
	      type = "zfs_fs";
	      mountpoint = "/persist";
	      options."com.sun:auto-snapshot" = "true";
	    };
	    "local/root" = {
	      type = "zfs_fs";
	      mountpoint = "/";
	      options."com.sun:auto-snapshot" = "false";
	      postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^zroot/local/root@blank$' || zfs snapshot zroot/local/root@blank";
	    };
	  };
        };
    };
  };
}
