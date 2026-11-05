# 7. Docker 볼륨 영속성 로그

## 7-1. 볼륨 생성 → 연결 → 데이터 기록

```bash
~/codyssey$ docker volume create mydata
mydata
~/codyssey$ docker volume ls
DRIVER    VOLUME NAME
local     mydata
~/codyssey$ docker run -d --name vol-test -v mydata:/data ubuntu sleep infinity
3766a3ec874aa3f6e3b062e060cef758ef9ef8406a527563e0395b0835d3b15f
~/codyssey$ docker exec vol-test bash -c "echo \"hi from vol-test (볼륨에 저장한 데이터)\" > /data/hello.txt && cat /data/hello.txt"
hi from vol-test (볼륨에 저장한 데이터)
```

## 7-2. 컨테이너 삭제 전/후 비교

```bash
~/codyssey$ docker rm -f vol-test
vol-test
~/codyssey$ docker ps -a --filter name=vol-test
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
~/codyssey$ docker volume ls
DRIVER    VOLUME NAME
local     mydata
~/codyssey$ docker run -d --name vol-test2 -v mydata:/data ubuntu sleep infinity
de9dd05ecd60cae9f16c4293e310cb172e1e2f754e05c15d7c46e8c5fafd38ee
~/codyssey$ docker exec vol-test2 cat /data/hello.txt
hi from vol-test (볼륨에 저장한 데이터)
~/codyssey$ docker volume inspect mydata
[
    {
        "CreatedAt": "2026-11-05T16:42:45Z",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/mydata/_data",
        "Name": "mydata",
        "Options": null,
        "Scope": "local"
    }
]
```

`vol-test` 컨테이너를 삭제했지만 볼륨 `mydata`는 남아 있었고, **새 컨테이너 `vol-test2`에 같은 볼륨을 연결하자 이전 데이터가 그대로 읽혔습니다.** 볼륨 데이터는 컨테이너가 아니라 Docker가 관리하는 별도 저장 공간(`Mountpoint`)에 저장되기 때문입니다.

## 7-3. 비교: 볼륨 없이 컨테이너 안에만 저장하면?

```bash
~/codyssey$ docker run -d --name novol-test ubuntu sleep infinity
6da1d2daf8cb605135536c92d3240d5b270357e53c8fcf32bc755a9a81753743
~/codyssey$ docker exec novol-test bash -c "echo \"컨테이너 안에만 저장한 데이터\" > /tmp/hello.txt && cat /tmp/hello.txt"
컨테이너 안에만 저장한 데이터
~/codyssey$ docker rm -f novol-test
novol-test
~/codyssey$ docker run -d --name novol-test ubuntu sleep infinity
e4080ef96dbd473af228d420c742688b01a7e325f3156335e600d722811f5208
~/codyssey$ docker exec novol-test cat /tmp/hello.txt
cat: /tmp/hello.txt: No such file or directory
[종료 코드: 1]
```

| 저장 위치 | 컨테이너 삭제 후 새 컨테이너에서 |
|---|---|
| 볼륨(`mydata:/data`) | ✅ 데이터 유지 |
| 컨테이너 내부(`/tmp`) | ❌ 데이터 사라짐 (`No such file or directory`) |

```bash
~/codyssey$ docker rm -f vol-test2 novol-test
vol-test2
novol-test
~/codyssey$ docker volume ls
DRIVER    VOLUME NAME
local     mydata
```

실습 컨테이너는 지웠지만 볼륨 `mydata`는 `docker volume rm mydata`로 직접 지우기 전까지 남습니다.

