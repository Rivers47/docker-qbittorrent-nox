# How to build
```shell
podman --build-arg QBT_VERSION=<version> -t qbittorrent-nox:<tag> -f Dockerfile
```
where `<version>` can be a qBittorrent version number or devel.

For version prior to 5.0.0 use Dockerfile-qt5

This Dockerfile allows you to build a Docker Image containing qBittorrent-nox

## Environment variable
* `QBT_WEBUI_PORT` \
  This environment variable sets the port number which qBittorrent WebUI will be binded to.
  Defaults to port `8080` if value is not set.

## Volumes

There are some paths involved:
* `<your_path>/config` \
  Full path to a folder on your host machine which will store qBittorrent configurations.
  Using relative path won't work.
* `<your_path>/downloads` \
  Full path to a folder on your host machine which will store the files downloaded by qBittorrent.
  Using relative path won't work.

## Running container
```shell
podman run -e QBT_WEBUI_PORT=<port> -p <port>:<port> \
    --tz local \
    -p 6881:6881/tcp -p 6881:6881/udp \
    --user $(id -u):$(id -g) --userns keep-id \
    --mount <your config and download volumes/paths> \
    localhost/qbittorrent-nox:tag
```


## A few notes:
  * By default the timezone in the container uses the default of Alpine Linux (which is most likely `UTC`).
    You can set the environment variable `TZ` to your preferred value.
  * It is possible to set the umask of the `qbittorrent-nox` process by setting the
    environment variable `UMASK`. By default it uses the default from Alpine Linux.
  * You can list the compile-time Software Bill of Materials (sbom) with the following command:
    ```shell
    docker run --entrypoint /bin/cat --rm qbittorrentofficial/qbittorrent-nox:latest /sbom.txt
    ```
  * Unlike linuxserver.io's version you cannot set the torrenting port when creating the container, but you can set
    it later in the webui
  * Map the webui port to a different port in the host system will result in Unauthroized error for security reason.
    It is therefore recommended to change the webui port via the environment variable
  * The legal notice confirmation is removed in the upstream repo
  * Tini is also removed

* Then you can login to qBittorrent-nox at: `http://<your_docker_host_address>:<port>`
  * For older qBittorrent versions (< 4.6.1), the default username/password is: `admin/adminadmin`.
  * For newer qBittorrent versions (≥ 4.6.1), qBittorrent will generate a temporary password and print it to the console (via stdout).
    You need to use it to login. See the [announcement](https://www.qbittorrent.org/news#mon-nov-20th-2023---qbittorrent-v4.6.1-release). \
    If you don't have a console attached, you can run `docker logs qbittorrent-nox` to show the logs.

  After logging in, don't forget to change the password to something else! \
  To change it in WebUI: 'Tools' menu -> 'Options...' -> 'Web UI' tab -> 'Authentication'
    If you don't need the GUI, you can just install Docker Engine: https://docs.docker.com/engine/install/

    It is also recommended to install Docker Compose as it can significantly ease the process: https://docs.docker.com/compose/install/

1. Download this repository

    You can either `git clone` this repository or download an .zip of it: https://github.com/qbittorrent/docker-qbittorrent-nox/archive/refs/heads/main.zip

2. Edit Docker environment file

    If you are using Docker Stack, refer to [docker-stack.yml](https://github.com/qbittorrent/docker-qbittorrent-nox/blob/main/docker-stack.yml) file as an example. \
    It is an almost ready-to-use configuration yet a few variables are required to be filled in. Make sure you read the following steps as they largely share the same concept.

    If you are not using Docker Compose you can skip editing the environment file.
    However the variables presented below is crucial in later steps, make sure you understand them.

    Find and open the `.env` file in the repository you cloned (or the .zip archive you downloaded). \
    There are a few variables that you must take care of before you can run the image. \
    You can find the meanings of these variables in the following section. Make sure you understand every one of them.

    #### Environment variables

    * `QBT_LEGAL_NOTICE` \
      This environment variable defines whether you had read the legal notice of qBittorrent. \
      **Put `confirm` only if you had read the legal notice.** You can find
      the legal notice [here](https://github.com/qbittorrent/qBittorrent/blob/56667e717b82c79433ecb8a5ff6cc2d7b315d773/src/app/main.cpp#L320-L323).
    * `QBT_VERSION` \
      This environment variable specifies the version of qBittorrent-nox to use. \
      For example, `4.4.5-1` is a valid entry. You can find all tagged versions [here](https://hub.docker.com/r/qbittorrentofficial/qbittorrent-nox/tags). \
      You can put `latest` to use the latest stable release of qBittorrent. \
      If you are up to test the bleeding-edge version, you can put `alpha` to get the weekly build.
    * `QBT_WEBUI_PORT` \
      This environment variable sets the port number which qBittorrent WebUI will be binded to.
      Defaults to port `8080` if value is not set.

    #### Volumes

    There are some paths involved:
    * `<your_path>/config` \
      Full path to a folder on your host machine which will store qBittorrent configurations.
      Using relative path won't work.
    * `<your_path>/downloads` \
      Full path to a folder on your host machine which will store the files downloaded by qBittorrent.
      Using relative path won't work.

3. Running the image

    * If using Docker (not Docker Compose), edit the variables and run:
      ```shell
      export \
        QBT_LEGAL_NOTICE=<put_confirm_here> \
        QBT_VERSION=latest \
        QBT_WEBUI_PORT=8080 \
        QBT_CONFIG_PATH="<your_path>/config" \
        QBT_DOWNLOADS_PATH="<your_path>/downloads"
      docker run \
        -t \
        --name qbittorrent-nox \
        --read-only \
        --rm \
        --stop-timeout 1800 \
        --tmpfs /tmp \
        -e QBT_LEGAL_NOTICE \
        -e QBT_WEBUI_PORT \
        -p "$QBT_WEBUI_PORT":"$QBT_WEBUI_PORT"/tcp \
        -p 6881:6881/tcp \
        -p 6881:6881/udp \
        -v "$QBT_CONFIG_PATH":/config \
        -v "$QBT_DOWNLOADS_PATH":/downloads \
        qbittorrentofficial/qbittorrent-nox:${QBT_VERSION}
      ```

    * If using Docker Compose:
      ```shell
      docker compose up
      ```

    * A few notes:
      * Alternatively, you can use `ghcr.io/qbittorrent/docker-qbittorrent-nox:${QBT_VERSION}`
        for the image path.
      * By default the timezone in the container uses the default of Alpine Linux (which is most likely `UTC`).
        You can set the environment variable `TZ` to your preferred value.
      * You can change the User ID (UID) and Group ID (GID) of the `qbittorrent-nox` process by setting
        environment variables `PUID` and `PGID` respectively. By default they are both set to `1000`. \
        Note that you will need to remove `--read-only` flag (when using Docker) or set
        `read_only: false` (when using Docker Compose) as they are incompatible with it.
      * You can set additional group ID (AGID) of the `qbittorrent-nox` process by setting the
        environment variable `PAGID`. For example: `10000,10001`, this will set the process to be in
        two (secondary) groups `10000` and `10001`. By default there is no additional group. \
        Note that you will need to remove `--read-only` flag (when using Docker) or set
        `read_only: false` (when using Docker Compose) as they are incompatible with it.
      * It is possible to set the umask of the `qbittorrent-nox` process by setting the
        environment variable `UMASK`. By default it uses the default from Alpine Linux.
      * You can list the compile-time Software Bill of Materials (sbom) with the following command:
        ```shell
        docker run --entrypoint /bin/cat --rm qbittorrentofficial/qbittorrent-nox:latest /sbom.txt
        ```

    * Then you can login to qBittorrent-nox at: `http://<your_docker_host_address>:8080`
      * For older qBittorrent versions (< 4.6.1), the default username/password is: `admin/adminadmin`.
      * For newer qBittorrent versions (≥ 4.6.1), qBittorrent will generate a temporary password and print it to the console (via stdout).
        You need to use it to login. See the [announcement](https://www.qbittorrent.org/news#mon-nov-20th-2023---qbittorrent-v4.6.1-release). \
        If you don't have a console attached, you can run `docker logs qbittorrent-nox` to show the logs.

      After logging in, don't forget to change the password to something else! \
      To change it in WebUI: 'Tools' menu -> 'Options...' -> 'Web UI' tab -> 'Authentication'

4. Stopping container

    * When using Docker (not Docker Compose):
      ```shell
      docker stop qbittorrent-nox
      ```

    * When using Docker Compose:
      ```shell
      docker compose down
      ```

## Build image manually

Refer to [manual_build](https://github.com/qbittorrent/docker-qbittorrent-nox/tree/main/manual_build) folder.

## Debugging

To attach gdb to the running qbittorent-nox process, follow the steps below:

1. Before you start the container
   * Remove `--read-only` as it will need additional packages within the container. \
     Or disable the respective attributes in docker-compose.yml.
   * Add `--cap-add=SYS_PTRACE` to `docker run` argument list. \
     Or enable the respective attributes in docker-compose.yml.

2. Start the container

3. Drop into container
   ```shell
   # to find container id
   docker ps
   # drop into container
   docker exec -it <container_id> /bin/sh
   ```

4. Install packages
   ```shell
   apk add \
     gdb \
     musl-dbg
   ```

5. Attach gdb to the running process
   ```shell
   # to find PID of qbittorrent-nox
   ps -a
   # attach debugger
   gdb -p <PID>
   ```
