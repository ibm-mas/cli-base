      #!/bin/bash

      # Install Rclone CLI
      set -e

      while [[ $# -gt 0 ]]
      do
          key="$1"

          case $key in
           --target-platform)
          TARGET_PLATFORM="$2"
          ;;
              *)
              # unknown option, use as additional params directly to docker
              EXTRA_PARAMS="$EXTRA_PARAMS $key $2"
              ;;
          esac
          shift
          shift
      done


      if [[ "$TARGET_PLATFORM" == "amd64" ]]; then
        curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip
        unzip rclone-current-linux-amd64.zip
        cp ./rclone-*-linux-amd64/rclone /usr/local/bin/
        rclone version
        rm -rf rclone-*
      else
        # doesnt have rclone-current.tar.gz
        curl -O  https://downloads.rclone.org/v1.67.0/rclone-v1.67.0.tar.gz
        tar -xvzf rclone-v1.67.0.tar.gz
        cd rclone-v1.67.0
        go build -o rclone
        ./rclone --version
        cp rclone /usr/bin/
        chmod +x /usr/bin/rclone
        rclone --version
        cd ..
        rm -rf rclone-*
      fi


      #[root@aca72e69ab39 rclone-v1.65.2-linux-mipsle]# rclone version
       #bash: /usr/local/bin/rclone: cannot execute binary file: Exec format error