# 5. Dockerfile 커스텀 이미지 · 포트 매핑 로그

## 5-1. 선택한 베이스와 커스텀 포인트

**선택: (A) 웹 서버 베이스 이미지 활용** → `nginx:stable-alpine` (공식 NGINX, Alpine 기반 경량 이미지)

| 커스텀 포인트 | 적용 내용 | 목적 |
|---|---|---|
| `LABEL` | 이미지 이름·설명·작성자 | `docker image inspect`로 이미지 출처를 확인할 수 있게 |
| `ENV APP_MODE, NGINX_PORT` | 실행 모드와 내부 포트를 환경 변수로 | 코드·이미지 수정 없이 `-e`로 설정 변경 (설정과 코드 분리) |
| `COPY nginx/default.conf.template` | 환경 변수가 채워지는 NGINX 설정 | `/health`, `/env` 엔드포인트와 `X-App-Mode` 헤더 추가 |
| `COPY app/` | 기본 Welcome 페이지 → 직접 만든 페이지 | 정적 콘텐츠 교체 |
| `HEALTHCHECK` | 10초마다 `/health` 호출 | `docker ps`에 `(healthy)` 상태 표시, 장애 감지 |

```bash
~/codyssey/E1-1$ ls -l
total 16
-rw-r--r-- 1 hunhun345 hunhun345 1195 Nov  6 01:40 Dockerfile
drwxr-xr-x 2 hunhun345 hunhun345 4096 Nov  6 01:40 app
drwxr-xr-x 3 hunhun345 hunhun345 4096 Nov  6 01:36 docs
drwxr-xr-x 2 hunhun345 hunhun345 4096 Nov  6 01:40 nginx
~/codyssey/E1-1$ cat Dockerfile
# 기존 베이스 이미지: 공식 NGINX 웹 서버 (Alpine Linux 기반 경량 버전)
FROM nginx:stable-alpine

# 커스텀 1) 이미지 메타데이터: 이미지의 이름·설명·작성자를 기록한다.
LABEL org.opencontainers.image.title="codyssey-e1-1-web" \
      org.opencontainers.image.description="Codyssey E1-1 custom NGINX web server" \
      org.opencontainers.image.authors="PSHUN03"

# 커스텀 2) 실행 설정을 환경 변수로 분리한다. (docker run -e 로 코드 수정 없이 변경 가능)
ENV APP_MODE=production \
    NGINX_PORT=80

# 커스텀 3) NGINX 설정 템플릿: 시작 시 환경 변수가 채워져 /etc/nginx/conf.d/default.conf가 된다.
COPY nginx/default.conf.template /etc/nginx/templates/default.conf.template

# 커스텀 4) 정적 콘텐츠 교체: 기본 "Welcome to nginx!" 페이지 대신 직접 만든 페이지를 제공한다.
COPY app/ /usr/share/nginx/html/

EXPOSE 80

# 커스텀 5) 헬스체크: 10초마다 /health를 호출해 컨테이너 상태(healthy/unhealthy)를 표시한다.
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -qO- "http://127.0.0.1:${NGINX_PORT}/health" || exit 1
```

## 5-2. 이미지 빌드

```bash
~/codyssey/E1-1$ docker build --progress=plain -t my-web:1.0 .
#0 building with "default" instance using docker driver

#1 [internal] load build definition from Dockerfile
#1 transferring dockerfile: 1.23kB done
#1 DONE 0.0s

#2 [internal] load metadata for docker.io/library/nginx:stable-alpine
#2 DONE 0.9s

#3 [internal] load .dockerignore
#3 transferring context: 2B done
#3 DONE 0.0s

#4 [internal] load build context
#4 transferring context: 131B done
#4 DONE 0.0s

#5 [1/3] FROM docker.io/library/nginx:stable-alpine@sha256:0e52bd054126cdc040b1276c0af347aeb02a41b9cfe305d6094767ac30e97949
#5 resolve docker.io/library/nginx:stable-alpine@sha256:0e52bd054126cdc040b1276c0af347aeb02a41b9cfe305d6094767ac30e97949 0.1s done
#5 DONE 0.1s

#6 [2/3] COPY nginx/default.conf.template /etc/nginx/templates/default.conf.template
#6 CACHED

#7 [3/3] COPY app/ /usr/share/nginx/html/
#7 CACHED

#8 exporting to image
#8 exporting layers done
#8 exporting manifest sha256:7db32f2074693b57372fb5cff90537f24f09e08aeb321c45e914c85aee08fc8a 0.0s done
#8 exporting config sha256:5b210b819e462d4485d3789bca3bee2cc47fd1dc9bebdf9495fb5a8fba279f9f 0.0s done
#8 exporting attestation manifest sha256:93c3e675fb733f175b5e679309e61cc7fe4634dc255d2ca73c3e27db38ba5aa8
#8 exporting attestation manifest sha256:93c3e675fb733f175b5e679309e61cc7fe4634dc255d2ca73c3e27db38ba5aa8 0.1s done
#8 exporting manifest list sha256:bd302375076a05e6f9b65d006f210a5142e2586e42cf3c96e5c19c5b721d7cab 0.0s done
#8 naming to docker.io/library/my-web:1.0
#8 naming to docker.io/library/my-web:1.0 done
#8 unpacking to docker.io/library/my-web:1.0
#8 unpacking to docker.io/library/my-web:1.0 0.9s done
#8 DONE 1.3s
~/codyssey/E1-1$ docker images my-web
IMAGE        ID             DISK USAGE   CONTENT SIZE   EXTRA
my-web:1.0   bd302375076a       92.7MB         26.1MB        
~/codyssey/E1-1$ docker image inspect my-web:1.0 --format "LABEL title = {{index .Config.Labels \"org.opencontainers.image.title\"}}"
LABEL title = codyssey-e1-1-web
~/codyssey/E1-1$ docker image inspect my-web:1.0 --format "ENV = {{json .Config.Env}}"
ENV = ["PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin","NGINX_VERSION=1.30.6","PKG_RELEASE=1","DYNPKG_RELEASE=1","NJS_VERSION=1.0.2","NJS_RELEASE=1","ACME_VERSION=0.4.1","APP_MODE=production","NGINX_PORT=80"]
```

## 5-3. 포트 매핑으로 실행 (같은 이미지 → 호스트 포트 8080, 8081)

```bash
~/codyssey/E1-1$ docker run -d -p 8080:80 --name my-web-8080 my-web:1.0
e18d34ef4d9fdad43406563dba26347079f14b14e6fd88ca4bce06ec524dbdb8
~/codyssey/E1-1$ docker run -d -p 8081:80 --name my-web-8081 my-web:1.0
545be79392456e5b606ee8737cb6a3817e4336c389b1aa824580a2b9845d7e12
~/codyssey/E1-1$ sleep 15
~/codyssey/E1-1$ docker ps --filter name=my-web
CONTAINER ID   IMAGE        COMMAND                  CREATED          STATUS                    PORTS                                     NAMES
545be7939245   my-web:1.0   "/docker-entrypoint.…"   15 seconds ago   Up 15 seconds (healthy)   0.0.0.0:8081->80/tcp, [::]:8081->80/tcp   my-web-8081
e18d34ef4d9f   my-web:1.0   "/docker-entrypoint.…"   17 seconds ago   Up 15 seconds (healthy)   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   my-web-8080
~/codyssey/E1-1$ docker port my-web-8080
80/tcp -> 0.0.0.0:8080
80/tcp -> [::]:8080
~/codyssey/E1-1$ curl -s http://localhost:8080 | grep -o "<title>.*</title>"
<title>Codyssey E1-1 · 나의 개발 작업실</title>
~/codyssey/E1-1$ curl -si http://localhost:8080/health
HTTP/1.1 200 OK
Server: nginx/1.30.6
Date: Thu, 05 Nov 2026 16:42:40 GMT
Content-Type: text/plain; charset=utf-8
Content-Length: 3
Connection: keep-alive
X-App-Mode: production

ok
~/codyssey/E1-1$ curl -s http://localhost:8081/env
{"app_mode": "production", "nginx_port": "80"}
~/codyssey/E1-1$ docker logs my-web-8080 2>&1 | tail -n 3
127.0.0.1 - - [05/Nov/2026:16:42:39 +0000] "GET /health HTTP/1.1" 200 3 "-" "Wget" "-"
172.17.0.1 - - [05/Nov/2026:16:42:40 +0000] "GET / HTTP/1.1" 200 2189 "-" "curl/8.18.0" "-"
172.17.0.1 - - [05/Nov/2026:16:42:40 +0000] "GET /health HTTP/1.1" 200 3 "-" "curl/8.18.0" "-"
```

같은 이미지로 컨테이너 2개를 띄웠고, 두 컨테이너 모두 **내부에서는 80번 포트**를 씁니다. 호스트 포트만 8080/8081로 다르게 연결했기 때문에 충돌 없이 동시에 접속됩니다. `docker ps`의 `(healthy)`는 Dockerfile의 HEALTHCHECK가 통과했다는 뜻입니다.

## 5-4. 포트 매핑이 없으면? (비교)

```bash
~/codyssey/E1-1$ docker run -d --name my-web-noport my-web:1.0
b48e685b76d3572e494becbe0da776439a96a10b254de567b734a19f9ba6c650
~/codyssey/E1-1$ docker ps --filter name=my-web-noport --format "{{.Names}}  PORTS=[{{.Ports}}]"
my-web-noport  PORTS=[80/tcp]
~/codyssey/E1-1$ curl -s --max-time 3 http://localhost:80 || echo "접속 실패 (호스트에 연결된 포트 없음)"
접속 실패 (호스트에 연결된 포트 없음)
~/codyssey/E1-1$ docker exec my-web-noport wget -qO- http://127.0.0.1/health
ok
~/codyssey/E1-1$ docker rm -f my-web-noport
my-web-noport
```

컨테이너는 **격리된 네트워크**에서 실행되므로, 안에서 80번 포트가 열려 있어도(`docker exec`로 내부 접속은 성공) 호스트(내 PC)에서는 접근할 수 없습니다. `-p 호스트포트:컨테이너포트`가 바깥(호스트)과 안(컨테이너)을 이어 주는 연결 통로 역할을 합니다.

