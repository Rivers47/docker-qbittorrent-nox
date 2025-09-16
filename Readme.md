# Intro
This is a personal build for using qbit with macvlan. This is so that you can run multiple instances of qbit on the same machine while also having ipv6 from your router, so you can set up port forwarding on your router.

# How to build
```shell
podman build --build-arg QBT_VERSION=<version> -t qbittorrent-nox:<tag> -f Dockerfile
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
