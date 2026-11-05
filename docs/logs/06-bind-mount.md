# 6. 바인드 마운트 반영 로그

호스트 폴더 `~/codyssey/bind-demo`를 컨테이너의 웹 루트(`/usr/share/nginx/html`)에 연결한 뒤, **컨테이너 재시작이나 이미지 재빌드 없이** 호스트에서 파일만 바꿔서 응답이 바뀌는지 확인합니다.

```bash
~/codyssey$ mkdir -p ~/codyssey/bind-demo
~/codyssey$ echo "<meta charset=utf-8><h1>바인드 마운트 테스트: 변경 전</h1>" > ~/codyssey/bind-demo/index.html
~/codyssey$ docker run -d -p 8082:80 --name my-web-bind -v ~/codyssey/bind-demo:/usr/share/nginx/html my-web:1.0
dc689756fd91fd2d8d9d95c64123f6c76a74fe7f5d4e134d377eba4fef1172b7
~/codyssey$ sleep 2
```

**변경 전**

```bash
~/codyssey$ cat ~/codyssey/bind-demo/index.html
<meta charset=utf-8><h1>바인드 마운트 테스트: 변경 전</h1>
~/codyssey$ curl -s http://localhost:8082
<meta charset=utf-8><h1>바인드 마운트 테스트: 변경 전</h1>
~/codyssey$ docker exec my-web-bind cat /usr/share/nginx/html/index.html
<meta charset=utf-8><h1>바인드 마운트 테스트: 변경 전</h1>
```

**호스트에서 파일 수정 → 변경 후** (컨테이너는 그대로 실행 중)

```bash
~/codyssey$ echo "<meta charset=utf-8><h1>바인드 마운트 테스트: 변경 후 (호스트에서 수정)</h1>" > ~/codyssey/bind-demo/index.html
~/codyssey$ curl -s http://localhost:8082
<meta charset=utf-8><h1>바인드 마운트 테스트: 변경 후 (호스트에서 수정)</h1>
~/codyssey$ docker exec my-web-bind cat /usr/share/nginx/html/index.html
<meta charset=utf-8><h1>바인드 마운트 테스트: 변경 후 (호스트에서 수정)</h1>
~/codyssey$ docker ps --filter name=my-web-bind --format "{{.Names}}  {{.Status}}"
my-web-bind  Up 2 seconds (health: starting)
~/codyssey$ docker inspect my-web-bind --format "{{json .Mounts}}"
[{"Type":"bind","Source":"/home/hunhun345/codyssey/bind-demo","Destination":"/usr/share/nginx/html","Mode":"","RW":true,"Propagation":"rprivate"}]
```

| 시점 | 호스트 파일 | `curl localhost:8082` 응답 |
|---|---|---|
| 변경 전 | 변경 전 | `<h1>바인드 마운트 테스트: 변경 전</h1>` |
| 호스트에서 수정 후 | 변경 후 | `<h1>바인드 마운트 테스트: 변경 후 (호스트에서 수정)</h1>` |

컨테이너의 `Status`가 계속 Up(재시작 없음)인데도 응답이 바뀌었습니다. 바인드 마운트는 호스트 폴더를 그대로 연결하므로 **개발 중 코드 수정을 즉시 반영**할 때 유용합니다. (마운트한 경로는 이미지 안의 기존 파일을 가리므로, 이 컨테이너에서는 이미지에 넣은 `index.html` 대신 호스트 파일이 보입니다.)

```bash
~/codyssey$ docker rm -f my-web-bind
my-web-bind
```

