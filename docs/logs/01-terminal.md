# 1. 터미널 조작 로그

실습 위치: `~/codyssey/practice` (WSL2 Ubuntu 홈 디렉터리 아래). 프롬프트의 `~`는 홈 디렉터리(`/home/hunhun345`)를 뜻합니다.

## 1-1. 현재 위치 확인 / 목록 확인(숨김 파일 포함)

```bash
~$ pwd
/home/hunhun345
~$ cd codyssey
~/codyssey$ pwd
/home/hunhun345/codyssey
~/codyssey$ ls
E1-1
~/codyssey$ ls -la
total 16
drwxr-xr-x  4 hunhun345 hunhun345 4096 Nov  6 01:37 .
drwxr-x--- 10 hunhun345 hunhun345 4096 Nov  6 01:34 ..
drwxr-xr-x  2 hunhun345 hunhun345 4096 Nov  6 01:37 .tools
drwxr-xr-x  4 hunhun345 hunhun345 4096 Nov  6 01:36 E1-1
```

`ls`는 이름이 `.`으로 시작하는 숨김 항목을 보여 주지 않고, `ls -la`는 숨김 항목(`.tools`)과 권한·소유자·크기까지 자세히 보여 줍니다. `.`은 현재 디렉터리, `..`은 상위 디렉터리입니다.
(홈 디렉터리 전체 목록에는 다른 프로그램의 설정 폴더 이름이 섞여 있어, 공개 저장소에 올리지 않도록 실습 폴더 기준으로 기록했습니다.)

## 1-2. 디렉터리 생성과 이동 (절대 경로 vs 상대 경로)

```bash
~/codyssey$ mkdir -p ~/codyssey/practice
~/codyssey$ cd /home/hunhun345/codyssey/practice
~/codyssey/practice$ pwd
/home/hunhun345/codyssey/practice
~/codyssey/practice$ mkdir docs backup
~/codyssey/practice$ ls -l
total 8
drwxr-xr-x 2 hunhun345 hunhun345 4096 Nov  6 01:37 backup
drwxr-xr-x 2 hunhun345 hunhun345 4096 Nov  6 01:37 docs
~/codyssey/practice$ cd docs
~/codyssey/practice/docs$ pwd
/home/hunhun345/codyssey/practice/docs
~/codyssey/practice/docs$ cd ..
~/codyssey/practice$ pwd
/home/hunhun345/codyssey/practice
~/codyssey/practice$ cd ../practice/backup
~/codyssey/practice/backup$ pwd
/home/hunhun345/codyssey/practice/backup
~/codyssey/practice/backup$ cd ~/codyssey/practice
~/codyssey/practice$ pwd
/home/hunhun345/codyssey/practice
```

- **절대 경로**: `/`(루트)부터 시작하는 전체 주소. 어디에서 실행해도 같은 위치를 가리킵니다. 예: `cd /home/hunhun345/codyssey/practice`
- **상대 경로**: 현재 위치를 기준으로 한 주소. `.`은 현재 디렉터리, `..`은 상위 디렉터리입니다. 예: `cd docs`, `cd ..`, `cd ../practice/backup`
- `~`는 홈 디렉터리를 줄여 쓴 표기라 `~/codyssey/practice`는 절대 경로와 같은 위치입니다.

## 1-3. 빈 파일 생성 / 파일 내용 작성·확인

```bash
~/codyssey/practice$ touch empty.txt .hidden_config
~/codyssey/practice$ ls -l
total 8
drwxr-xr-x 2 hunhun345 hunhun345 4096 Nov  6 01:37 backup
drwxr-xr-x 2 hunhun345 hunhun345 4096 Nov  6 01:37 docs
-rw-r--r-- 1 hunhun345 hunhun345    0 Nov  6 01:37 empty.txt
~/codyssey/practice$ ls -la
total 16
drwxr-xr-x 4 hunhun345 hunhun345 4096 Nov  6 01:37 .
drwxr-xr-x 5 hunhun345 hunhun345 4096 Nov  6 01:37 ..
-rw-r--r-- 1 hunhun345 hunhun345    0 Nov  6 01:37 .hidden_config
drwxr-xr-x 2 hunhun345 hunhun345 4096 Nov  6 01:37 backup
drwxr-xr-x 2 hunhun345 hunhun345 4096 Nov  6 01:37 docs
-rw-r--r-- 1 hunhun345 hunhun345    0 Nov  6 01:37 empty.txt
~/codyssey/practice$ echo "안녕하세요, 코디세이 E1-1 터미널 실습입니다." > notes.txt
~/codyssey/practice$ echo "두 번째 줄: >> 는 기존 내용 뒤에 덧붙입니다." >> notes.txt
~/codyssey/practice$ cat notes.txt
안녕하세요, 코디세이 E1-1 터미널 실습입니다.
두 번째 줄: >> 는 기존 내용 뒤에 덧붙입니다.
~/codyssey/practice$ cat empty.txt
~/codyssey/practice$ ls -l empty.txt notes.txt
-rw-r--r-- 1 hunhun345 hunhun345   0 Nov  6 01:37 empty.txt
-rw-r--r-- 1 hunhun345 hunhun345 123 Nov  6 01:37 notes.txt
```

`touch`로 만든 `empty.txt`는 크기가 0바이트라 `cat`을 해도 아무것도 출력되지 않습니다. `.hidden_config`는 숨김 파일이라 `ls -l`에는 없고 `ls -la`에만 보입니다.

## 1-4. 복사 / 이동 / 이름 변경

```bash
~/codyssey/practice$ cp notes.txt backup/notes_copy.txt
~/codyssey/practice$ ls -l backup
total 4
-rw-r--r-- 1 hunhun345 hunhun345 123 Nov  6 01:37 notes_copy.txt
~/codyssey/practice$ mv notes.txt docs/
~/codyssey/practice$ ls -l . docs
.:
total 8
drwxr-xr-x 2 hunhun345 hunhun345 4096 Nov  6 01:37 backup
drwxr-xr-x 2 hunhun345 hunhun345 4096 Nov  6 01:37 docs
-rw-r--r-- 1 hunhun345 hunhun345    0 Nov  6 01:37 empty.txt

docs:
total 4
-rw-r--r-- 1 hunhun345 hunhun345 123 Nov  6 01:37 notes.txt
~/codyssey/practice$ mv docs/notes.txt docs/memo.txt
~/codyssey/practice$ ls -l docs
total 4
-rw-r--r-- 1 hunhun345 hunhun345 123 Nov  6 01:37 memo.txt
~/codyssey/practice$ cat docs/memo.txt
안녕하세요, 코디세이 E1-1 터미널 실습입니다.
두 번째 줄: >> 는 기존 내용 뒤에 덧붙입니다.
```

`mv`는 대상이 디렉터리면 **이동**, 같은 디렉터리 안에서 새 이름을 주면 **이름 변경**입니다.

## 1-5. 삭제

```bash
~/codyssey/practice$ rm empty.txt
~/codyssey/practice$ rm backup/notes_copy.txt
~/codyssey/practice$ rmdir backup
~/codyssey/practice$ ls -la
total 12
drwxr-xr-x 3 hunhun345 hunhun345 4096 Nov  6 01:37 .
drwxr-xr-x 5 hunhun345 hunhun345 4096 Nov  6 01:37 ..
-rw-r--r-- 1 hunhun345 hunhun345    0 Nov  6 01:37 .hidden_config
drwxr-xr-x 2 hunhun345 hunhun345 4096 Nov  6 01:37 docs
~/codyssey/practice$ rm -r docs
~/codyssey/practice$ ls -la
total 8
drwxr-xr-x 2 hunhun345 hunhun345 4096 Nov  6 01:37 .
drwxr-xr-x 5 hunhun345 hunhun345 4096 Nov  6 01:37 ..
-rw-r--r-- 1 hunhun345 hunhun345    0 Nov  6 01:37 .hidden_config
```

`rm`은 파일, `rmdir`은 빈 디렉터리, `rm -r`은 디렉터리와 그 안의 내용을 모두 삭제합니다. (휴지통 없이 바로 지워지므로 주의)

