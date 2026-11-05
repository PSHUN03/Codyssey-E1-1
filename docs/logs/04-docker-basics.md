# 4. Docker 기본 운영 · 컨테이너 실습 로그

## 4-1. hello-world 실행

```bash
~/codyssey$ docker run --name hello hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

~/codyssey$ docker ps -a --filter name=hello
CONTAINER ID   IMAGE         COMMAND    CREATED        STATUS                              PORTS     NAMES
23af535f745c   hello-world   "/hello"   1 second ago   Exited (0) Less than a second ago             hello
~/codyssey$ docker logs hello | head -3

Hello from Docker!
This message shows that your installation appears to be working correctly.
```

hello-world 컨테이너는 메시지를 출력하고 바로 종료되므로 `docker ps`(실행 중)에는 없고 `docker ps -a`(종료 포함)에 `Exited (0)`으로 남습니다.

## 4-2. 이미지 다운로드 / 목록 확인

```bash
~/codyssey$ docker pull ubuntu
Using default tag: latest
latest: Pulling from library/ubuntu
Digest: sha256:6a06111c3b0a8600feadb270aec771dc239bf407b25625f93f44ab00e11f4d3c
Status: Image is up to date for ubuntu:latest
docker.io/library/ubuntu:latest
~/codyssey$ docker images
IMAGE                ID             DISK USAGE   CONTENT SIZE   EXTRA
hello-world:latest   c567b231f656       25.9kB         9.49kB   U    
ubuntu:latest        6a06111c3b0a        163MB         45.9MB        
```

## 4-3. ubuntu 컨테이너 내부 진입 후 명령 실행

`-it`는 키보드 입력(`-i`)과 터미널 화면(`-t`)을 연결해 컨테이너 안의 bash를 직접 쓰게 해 줍니다. 프롬프트가 `root@<컨테이너ID>:/#`로 바뀌면 컨테이너 내부입니다.

```bash
~/codyssey$ docker run -it --name ubuntu-it ubuntu bash
root@5507c1212fc8:/# ls
bin   dev  home  lib64  mnt  proc  run   srv  tmp  var
boot  etc  lib   media  opt  root  sbin  sys  usr
root@5507c1212fc8:/# echo "Hello from ubuntu container"
Hello from ubuntu container
root@5507c1212fc8:/# cat /etc/os-release | head -2
PRETTY_NAME="Ubuntu 26.04.1 LTS"
NAME="Ubuntu"
root@5507c1212fc8:/# exit
exit
~/codyssey$ docker ps -a --filter name=ubuntu-it
CONTAINER ID   IMAGE     COMMAND   CREATED         STATUS                     PORTS     NAMES
5507c1212fc8   ubuntu    "bash"    7 seconds ago   Exited (0) 2 seconds ago             ubuntu-it
```

내부에서 `exit`하면 컨테이너의 메인 프로세스(bash)가 끝나므로 컨테이너도 `Exited` 상태가 됩니다.

## 4-4. 컨테이너 종료/유지 차이: attach vs exec

같은 컨테이너(`ubuntu-bg`)를 백그라운드로 띄워 두고, `exec`와 `attach`로 각각 들어갔다 나온 뒤 상태를 비교합니다.

```bash
~/codyssey$ docker run -dit --name ubuntu-bg ubuntu bash
15c27f3136f8d23a74acce38f2906b80f24d4e47fcc00fe041af387bbeaf19fd
~/codyssey$ docker ps --filter name=ubuntu-bg
CONTAINER ID   IMAGE     COMMAND   CREATED        STATUS                  PORTS     NAMES
15c27f3136f8   ubuntu    "bash"    1 second ago   Up Less than a second             ubuntu-bg
```

**① exec: 새 bash 프로세스를 추가로 띄워 들어간다 → exit 해도 컨테이너 유지**

```bash
~/codyssey$ docker exec -it ubuntu-bg bash
root@15c27f3136f8:/# echo "Hello from exec (new bash process)"
Hello from exec (new bash process)
root@15c27f3136f8:/# exit
exit
~/codyssey$ docker ps --filter name=ubuntu-bg
CONTAINER ID   IMAGE     COMMAND   CREATED         STATUS         PORTS     NAMES
15c27f3136f8   ubuntu    "bash"    6 seconds ago   Up 5 seconds             ubuntu-bg
~/codyssey$ docker exec ubuntu-bg ls /
bin
boot
dev
etc
home
lib
lib64
media
mnt
opt
proc
root
run
sbin
srv
sys
tmp
usr
var
```

**② attach: 컨테이너의 메인 프로세스(PID 1 bash)에 직접 연결 → exit 하면 컨테이너 종료**

```bash
~/codyssey$ docker attach ubuntu-bg
root@15c27f3136f8:/# echo "Hello from attach (main process, PID 1)"
Hello from attach (main process, PID 1)

exit
~/codyssey$ docker ps -a --filter name=ubuntu-bg
CONTAINER ID   IMAGE     COMMAND   CREATED          STATUS                     PORTS     NAMES
15c27f3136f8   ubuntu    "bash"    11 seconds ago   Exited (0) 2 seconds ago             ubuntu-bg
```

**③ attach 상태에서 종료하지 않고 빠져나오기: Ctrl+P → Ctrl+Q**

```bash
~/codyssey$ docker start ubuntu-bg
ubuntu-bg
~/codyssey$ docker attach ubuntu-bg
root@15c27f3136f8:/# read escape sequence
~/codyssey$ docker ps --filter name=ubuntu-bg
CONTAINER ID   IMAGE     COMMAND   CREATED          STATUS         PORTS     NAMES
15c27f3136f8   ubuntu    "bash"    15 seconds ago   Up 4 seconds             ubuntu-bg
```

| 방식 | 연결 대상 | 빠져나올 때 | 컨테이너 상태 |
|---|---|---|---|
| `docker exec -it <이름> bash` | **새로 띄운** bash 프로세스 | `exit` | 유지 (Up) |
| `docker attach <이름>` | **메인 프로세스(PID 1)** | `exit` | 종료 (Exited) |
| `docker attach <이름>` | 메인 프로세스(PID 1) | `Ctrl+P`, `Ctrl+Q` (detach) | 유지 (Up) |

정리하면, 실행 중인 컨테이너에 들어가 점검할 때는 **exec**가 안전합니다. attach에서 `exit`하면 메인 프로세스가 끝나 서비스가 멈추기 때문입니다.

## 4-5. 로그 / 리소스 확인 (logs, stats)

```bash
~/codyssey$ docker run -d --name stats-demo ubuntu bash -c 'for i in 1 2 3; do echo "작업 로그 $i"; sleep 1; done; sleep infinity'
9d57a89ab9f8b30352f56bec0d0847b0ad4126910a27c49779a8278e82e20d24
~/codyssey$ sleep 4
~/codyssey$ docker logs stats-demo
작업 로그 1
작업 로그 2
작업 로그 3
~/codyssey$ docker logs -t --tail 1 stats-demo
2026-11-05T16:39:17.332802958Z 작업 로그 3
~/codyssey$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS         PORTS     NAMES
9d57a89ab9f8   ubuntu    "bash -c 'for i in 1…"   5 seconds ago    Up 4 seconds             stats-demo
15c27f3136f8   ubuntu    "bash"                   20 seconds ago   Up 9 seconds             ubuntu-bg
~/codyssey$ docker stats --no-stream
CONTAINER ID   NAME         CPU %     MEM USAGE / LIMIT     MEM %     NET I/O        BLOCK I/O   PIDS
9d57a89ab9f8   stats-demo   0.00%     3.102MiB / 7.602GiB   0.04%     872B / 126B    0B / 0B     1
15c27f3136f8   ubuntu-bg    0.00%     1.426MiB / 7.602GiB   0.02%     1.3kB / 126B   0B / 0B     1
```

`docker logs`는 컨테이너 메인 프로세스가 표준 출력으로 낸 내용을 보여 주고, `docker stats --no-stream`은 실행 중인 컨테이너의 CPU·메모리·네트워크·프로세스 수를 한 번 출력합니다(옵션을 빼면 실시간 갱신).

## 4-6. 중지 / 삭제 정리

```bash
~/codyssey$ docker stop ubuntu-bg
ubuntu-bg
~/codyssey$ docker ps -a
CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS                                PORTS     NAMES
9d57a89ab9f8   ubuntu        "bash -c 'for i in 1…"   10 seconds ago   Up 9 seconds                                    stats-demo
15c27f3136f8   ubuntu        "bash"                   25 seconds ago   Exited (137) Less than a second ago             ubuntu-bg
5507c1212fc8   ubuntu        "bash"                   32 seconds ago   Exited (0) 27 seconds ago                       ubuntu-it
23af535f745c   hello-world   "/hello"                 35 seconds ago   Exited (0) 34 seconds ago                       hello
592f0cde6b77   hello-world   "/hello"                 11 minutes ago   Exited (0) 11 minutes ago                       nervous_robinson
~/codyssey$ docker rm -f hello ubuntu-it ubuntu-bg stats-demo
hello
ubuntu-it
ubuntu-bg
stats-demo
~/codyssey$ docker ps -a
CONTAINER ID   IMAGE         COMMAND    CREATED          STATUS                      PORTS     NAMES
592f0cde6b77   hello-world   "/hello"   11 minutes ago   Exited (0) 11 minutes ago             nervous_robinson
```

`ubuntu-bg`가 `Exited (137)`인 이유: `docker stop`은 먼저 정상 종료 신호(SIGTERM)를 보내고 10초 기다립니다. 그런데 PID 1로 실행 중인 bash는 이 신호를 무시하므로, 10초 뒤 강제 종료 신호(SIGKILL, 9번)로 끝났습니다. 종료 코드 137 = 128 + 9(SIGKILL)입니다.

`docker stop`은 컨테이너를 멈추기만 하고(`Exited`), `docker rm`이 삭제합니다. `-f`는 실행 중인 컨테이너도 강제로 멈춘 뒤 삭제합니다. 이미지(`docker images`)는 컨테이너를 지워도 남습니다.

