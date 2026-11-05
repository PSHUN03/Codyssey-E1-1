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
