# 9. Git 설정 · GitHub 연동 로그

## 9-1. 사용자 정보 / 기본 브랜치 설정 확인

WSL Ubuntu 안의 Git은 Windows와 설정 파일이 따로라서 Ubuntu에서 다시 설정했습니다. (`git config --global user.name`, `user.email`, `init.defaultBranch`)

```bash
~/codyssey/E1-1$ git --version
git version 2.53.0
~/codyssey/E1-1$ git config --global --list
user.name=PSHUN03
user.email=301172814+PSHUN03@users.noreply.github.com
init.defaultbranch=main
credential.helper=/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe
~/codyssey/E1-1$ git config --list
user.name=PSHUN03
user.email=301172814+PSHUN03@users.noreply.github.com
init.defaultbranch=main
credential.helper=/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe
core.repositoryformatversion=0
core.filemode=true
core.bare=false
core.logallrefupdates=true
remote.origin.url=https://github.com/PSHUN03/Codyssey-E1-1.git
remote.origin.fetch=+refs/heads/*:refs/remotes/origin/*
```

- `user.email`은 개인 이메일이 공개되지 않도록 GitHub noreply 주소를 사용합니다. (개인 이메일로 push하면 GitHub의 이메일 보호 설정에 의해 거절될 수 있음)
- `credential.helper`는 WSL의 Git이 Windows의 Git Credential Manager로 GitHub 로그인을 처리하게 합니다. 토큰을 파일이나 명령에 직접 쓰지 않습니다.

## 9-2. 원격 저장소 연결과 push

```bash
~/codyssey/E1-1$ git remote -v
origin	https://github.com/PSHUN03/Codyssey-E1-1.git (fetch)
origin	https://github.com/PSHUN03/Codyssey-E1-1.git (push)
~/codyssey/E1-1$ git branch
* main
~/codyssey/E1-1$ git log --oneline
fb62db6 Docs: README 기술 문서 작성 및 설치 과정 화면 추가
8549cf9 Feat: Docker Compose 보너스 실습 (단일/멀티 컨테이너, 환경 변수)
5b4e56f Docs: 바인드 마운트 반영 및 볼륨 영속성 검증 로그 추가
2fbb7e6 Feat: NGINX 기반 커스텀 웹 서버 이미지 작성
54d1d53 Docs: Docker 설치 점검 및 기본 운영 실습 로그 추가
16717f7 Docs: 터미널 조작 및 권한 실습 로그 추가
~/codyssey/E1-1$ git status -s
?? docs/logs/09-git.md
~/codyssey/E1-1$ git push -u origin main
To https://github.com/PSHUN03/Codyssey-E1-1.git
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'.
~/codyssey/E1-1$ git status -sb | head -1
## main...origin/main
~/codyssey/E1-1$ git log --oneline -1 origin/main
fb62db6 Docs: README 기술 문서 작성 및 설치 과정 화면 추가
```

`main...origin/main`은 로컬 `main` 브랜치가 GitHub의 `origin/main`을 추적하고 있다는 뜻이고, 뒤에 `[ahead N]` 표시가 없으면 모든 커밋이 GitHub에 올라간 상태입니다.

