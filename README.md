Create a custom Ubuntu autoinstall image
===

Build Docker image
---
```
docker build -t create_autoinstall_iso .
```

Remove unused docker images
---
```
docker images -a --filter=dangling=true -q | xargs -r docker rmi
```


Create custom boot image
---

Example:
```
docker run --privileged -v $(pwd):/opt/work -t create_autoinstall_iso \
    /bin/bash customiso \
    --isolinuxcfg txt.cfg \
    --grubcfg grub.cfg \
    --customscript customconfig --autoinstall user-data \
    --output-bootiso ubuntu-20.04.3-amd64-autoinstall.iso  \   
    ubuntu-20.04.3-live-server-amd64.iso  --overwrite
```

Remove all stoped dockers
---
```
docker ps --filter=status=created --filter=status=exited -q | xargs -r docker rm
```

