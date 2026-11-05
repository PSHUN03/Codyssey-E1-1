# 8. 보너스: Docker Compose 로그

## 8-1. Compose 기초: 단일 서비스 실행

```bash
~/codyssey/E1-1$ cat docker-compose.yml
# 보너스: docker run 명령에 흩어져 있던 실행 설정(이미지, 포트, 환경 변수, 마운트)을 파일로 문서화한다.
# ${변수:-기본값} 은 셸 환경 변수나 .env 파일 값이 있으면 그 값을, 없으면 기본값을 쓴다.

services:
  # 웹 서버: 이 저장소의 Dockerfile로 만든 커스텀 NGINX 이미지
  web:
    build: .
    image: my-web:compose
    ports:
      - "${WEB_PORT:-8090}:${NGINX_PORT:-80}"
    environment:
      APP_MODE: ${APP_MODE:-development}
      NGINX_PORT: ${NGINX_PORT:-80}

  # 보조 서비스: Python 표준 라이브러리 웹 서버로 api/ 폴더의 JSON을 제공한다.
  # ports를 공개하지 않았으므로 호스트에서는 접근할 수 없고, 같은 Compose 네트워크의 web만 접근한다.
  api:
    image: python:3.13-alpine
    command: python -m http.server 8000 --directory /srv
    volumes:
      - ./api:/srv:ro
    expose:
      - "8000"
~/codyssey/E1-1$ docker compose config --services
api
web
~/codyssey/E1-1$ docker compose build --quiet web
 Image my-web:compose Building 
 Image my-web:compose Built 
~/codyssey/E1-1$ docker compose up -d web
 Network e1-1_default Creating 
 Network e1-1_default Creating 
 Network e1-1_default Created 
 Network e1-1_default Created 
 Container e1-1-web-1 Creating 
 Container e1-1-web-1 Created 
 Container e1-1-web-1 Starting 
 Container e1-1-web-1 Started 
~/codyssey/E1-1$ sleep 12
~/codyssey/E1-1$ docker compose ps
NAME         IMAGE            COMMAND                  SERVICE   CREATED          STATUS                    PORTS
e1-1-web-1   my-web:compose   "/docker-entrypoint.…"   web       13 seconds ago   Up 12 seconds (healthy)   0.0.0.0:8090->80/tcp, [::]:8090->80/tcp
~/codyssey/E1-1$ curl -s http://localhost:8090/env
{"app_mode": "development", "nginx_port": "80"}
```

**배움 포인트: 실행 명령이 "문서화된 실행 설정"으로 바뀌는 이유**

| `docker run` 방식 | Compose 방식 |
|---|---|
| `docker build -t my-web:compose .` + `docker run -d -p 8090:80 -e APP_MODE=development -e NGINX_PORT=80 my-web:compose` | `docker compose up -d web` |
| 옵션을 매번 기억하고 정확히 다시 입력해야 함 | 옵션이 `docker-compose.yml`에 남아 있어 누구나 같은 명령으로 같은 환경을 재현 |
| 설정이 바뀐 기록이 남지 않음 | 파일이라 Git으로 변경 이력 관리 가능 |

## 8-2. 멀티 컨테이너: web + api, 서비스 이름으로 통신

```bash
~/codyssey/E1-1$ cat api/status.json
{
  "service": "api",
  "message": "web 컨테이너가 서비스 이름(api)으로 찾아와 받은 응답입니다."
}
~/codyssey/E1-1$ docker compose up -d
 Container e1-1-web-1 Running 
 Container e1-1-api-1 Creating 
 Container e1-1-api-1 Created 
 Container e1-1-api-1 Starting 
 Container e1-1-api-1 Started 
~/codyssey/E1-1$ docker compose ps
NAME         IMAGE                COMMAND                  SERVICE   CREATED          STATUS                    PORTS
e1-1-api-1   python:3.13-alpine   "python -m http.serv…"   api       1 second ago     Up Less than a second     8000/tcp
e1-1-web-1   my-web:compose       "/docker-entrypoint.…"   web       14 seconds ago   Up 13 seconds (healthy)   0.0.0.0:8090->80/tcp, [::]:8090->80/tcp
~/codyssey/E1-1$ docker network ls --filter name=e1-1
NETWORK ID     NAME           DRIVER    SCOPE
44078bf5c7de   e1-1_default   bridge    local
~/codyssey/E1-1$ docker compose exec web nslookup api
Server:		127.0.0.11
Address:	127.0.0.11:53

Non-authoritative answer:

Non-authoritative answer:
Name:	api
Address: 172.18.0.3

~/codyssey/E1-1$ docker compose exec web wget -qO- http://api:8000/status.json
{
  "service": "api",
  "message": "web 컨테이너가 서비스 이름(api)으로 찾아와 받은 응답입니다."
}
~/codyssey/E1-1$ curl -s --max-time 3 http://localhost:8000/status.json || echo "호스트에서는 api에 접근 불가 (ports 미공개)"
호스트에서는 api에 접근 불가 (ports 미공개)
```

**배움 포인트: 네트워크 / 서비스 디스커버리**
- Compose는 프로젝트마다 전용 네트워크(`e1-1_default`)를 만들고 모든 서비스를 여기에 연결합니다.
- 같은 네트워크 안에서는 **서비스 이름(`api`)이 곧 주소**가 됩니다. Docker 내장 DNS(`127.0.0.11`)가 `api`를 해당 컨테이너의 IP로 바꿔 주므로, IP를 몰라도 `http://api:8000`으로 통신할 수 있습니다.
- `api`는 `ports`를 공개하지 않았기 때문에 같은 네트워크의 `web`만 접근할 수 있고, 호스트에서는 접근할 수 없습니다. (내부 서비스 보호)

## 8-3. Compose 운영 명령: ps / logs / down

```bash
~/codyssey/E1-1$ docker compose ps
NAME         IMAGE                COMMAND                  SERVICE   CREATED          STATUS                    PORTS
e1-1-api-1   python:3.13-alpine   "python -m http.serv…"   api       1 second ago     Up Less than a second     8000/tcp
e1-1-web-1   my-web:compose       "/docker-entrypoint.…"   web       14 seconds ago   Up 13 seconds (healthy)   0.0.0.0:8090->80/tcp, [::]:8090->80/tcp
~/codyssey/E1-1$ docker compose logs --tail 3 web
web-1  | 2026/11/05 16:44:32 [notice] 1#1: start worker process 47
web-1  | 127.0.0.1 - - [05/Nov/2026:16:44:37 +0000] "GET /health HTTP/1.1" 200 3 "-" "Wget" "-"
web-1  | 172.18.0.1 - - [05/Nov/2026:16:44:44 +0000] "GET /env HTTP/1.1" 200 48 "-" "curl/8.18.0" "-"
~/codyssey/E1-1$ docker compose logs --tail 3 api
api-1  | 172.18.0.2 - - [05/Nov/2026 16:44:45] "GET /status.json HTTP/1.1" 200 -
~/codyssey/E1-1$ docker compose down
 Container e1-1-api-1 Stopping 
 Container e1-1-web-1 Stopping 
 Container e1-1-web-1 Stopped 
 Container e1-1-web-1 Removing 
 Container e1-1-web-1 Removed 
 Container e1-1-api-1 Stopped 
 Container e1-1-api-1 Removing 
 Container e1-1-api-1 Removed 
 Network e1-1_default Removing 
 Network e1-1_default Removed 
~/codyssey/E1-1$ docker compose ps -a
NAME      IMAGE     COMMAND   SERVICE   CREATED   STATUS    PORTS
~/codyssey/E1-1$ docker network ls --filter name=e1-1
NETWORK ID   NAME      DRIVER    SCOPE
```

**배움 포인트: 상태 확인 루틴**

| 명령 | 용도 |
|---|---|
| `docker compose up -d` | 정의된 서비스 전체를 백그라운드로 실행 (없으면 생성, 바뀐 설정이 있으면 재생성) |
| `docker compose ps` | 서비스별 상태, 헬스체크, 포트 확인 |
| `docker compose logs --tail N <서비스>` | 서비스별 최근 로그 확인 (`-f`를 붙이면 실시간) |
| `docker compose down` | 컨테이너와 전용 네트워크를 함께 정리 (이미지·이름 있는 볼륨은 유지) |

## 8-4. 환경 변수로 포트 / 모드 바꾸기

```bash
~/codyssey/E1-1$ cat .env.example
# docker compose 실행 설정 예시. 사용하려면 복사해서 .env로 저장한다. (cp .env.example .env)
# .env는 .gitignore로 저장소에서 제외한다.

# 호스트에서 접속할 포트 (브라우저 주소: http://localhost:WEB_PORT)
WEB_PORT=8090

# 실행 모드: 응답 헤더 X-App-Mode와 /env 응답에 표시된다.
APP_MODE=development

# 컨테이너 안에서 NGINX가 듣는 포트
NGINX_PORT=80
~/codyssey/E1-1$ WEB_PORT=8091 NGINX_PORT=8000 APP_MODE=staging docker compose up -d web
 Network e1-1_default Creating 
 Network e1-1_default Creating 
 Network e1-1_default Created 
 Network e1-1_default Created 
 Container e1-1-web-1 Creating 
 Container e1-1-web-1 Created 
 Container e1-1-web-1 Starting 
 Container e1-1-web-1 Started 
~/codyssey/E1-1$ sleep 12
~/codyssey/E1-1$ docker compose ps
NAME         IMAGE            COMMAND                  SERVICE   CREATED          STATUS                    PORTS
e1-1-web-1   my-web:compose   "/docker-entrypoint.…"   web       13 seconds ago   Up 12 seconds (healthy)   0.0.0.0:8091->8000/tcp, [::]:8091->8000/tcp
~/codyssey/E1-1$ curl -si http://localhost:8091/env
HTTP/1.1 200 OK
Server: nginx/1.30.6
Date: Thu, 05 Nov 2026 16:45:03 GMT
Content-Type: application/json
Content-Length: 46
Connection: keep-alive
X-App-Mode: staging

{"app_mode": "staging", "nginx_port": "8000"}
~/codyssey/E1-1$ docker compose exec web grep -E "listen|X-App-Mode" /etc/nginx/conf.d/default.conf
    listen       8000;
    add_header X-App-Mode "staging" always;
~/codyssey/E1-1$ docker compose down
 Container e1-1-web-1 Stopping 
 Container e1-1-web-1 Stopped 
 Container e1-1-web-1 Removing 
 Container e1-1-web-1 Removed 
 Network e1-1_default Removing 
 Network e1-1_default Removed 
```

**배움 포인트: 설정과 코드의 분리**
- 같은 이미지(`my-web:compose`)와 같은 `docker-compose.yml`인데, 환경 변수만 바꿔서 실행 설정이 달라졌습니다.
  - 호스트 포트: 8090 → **8091**
  - 컨테이너 내부 포트: 80 → **8000**
  - 실행 모드: development → **staging**
- 코드나 이미지를 고치지 않고 실행 환경(개발/검증/운영)에 맞춰 설정만 바꿀 수 있습니다.
- 실제 값은 `.env` 파일에 두고 `.gitignore`로 저장소에서 제외합니다. 저장소에는 예시(`.env.example`)만 올립니다.

