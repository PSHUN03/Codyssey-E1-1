# 2. 권한 실습 로그

실습 위치: `~/codyssey/practice`. 파일 1개(`hello.sh`)와 디렉터리 1개(`secret_dir`)의 권한을 바꾸고, 변경 전/후를 비교합니다.

## 2-1. 파일 권한: 실행 권한(x)이 없을 때 → 755로 변경 후

```bash
~/codyssey/practice$ umask
0022
~/codyssey/practice$ printf "#!/bin/bash\necho \"스크립트 실행 성공! (실행 권한 확인)\"\n" > hello.sh
~/codyssey/practice$ ls -l hello.sh
-rw-r--r-- 1 hunhun345 hunhun345 70 Nov  6 01:37 hello.sh
~/codyssey/practice$ stat -c "%A  %a  %n" hello.sh
-rw-r--r--  644  hello.sh
~/codyssey/practice$ ./hello.sh
bash: ./hello.sh: Permission denied
[종료 코드: 126]
~/codyssey/practice$ chmod 755 hello.sh
~/codyssey/practice$ ls -l hello.sh
-rwxr-xr-x 1 hunhun345 hunhun345 70 Nov  6 01:37 hello.sh
~/codyssey/practice$ stat -c "%A  %a  %n" hello.sh
-rwxr-xr-x  755  hello.sh
~/codyssey/practice$ ./hello.sh
스크립트 실행 성공! (실행 권한 확인)
~/codyssey/practice$ chmod 644 hello.sh
~/codyssey/practice$ stat -c "%A  %a  %n" hello.sh
-rw-r--r--  644  hello.sh
~/codyssey/practice$ chmod u+x hello.sh
~/codyssey/practice$ stat -c "%A  %a  %n" hello.sh
-rwxr--r--  744  hello.sh
```

| 시점 | 권한 | 결과 |
|---|---|---|
| 생성 직후 (umask 0022 적용) | `-rw-r--r--` (644) | `./hello.sh` → Permission denied |
| `chmod 755` 후 | `-rwxr-xr-x` (755) | 실행 성공 |
| `chmod 644` → `chmod u+x` | 644 → `-rwxr--r--` (744) | 기호 방식으로 소유자에게만 x 추가 |

## 2-2. 디렉터리 권한: 실행 권한(x)을 빼면 들어갈 수 없다

```bash
~/codyssey/practice$ mkdir secret_dir
~/codyssey/practice$ echo "디렉터리 안의 파일" > secret_dir/inside.txt
~/codyssey/practice$ ls -ld secret_dir
drwxr-xr-x 2 hunhun345 hunhun345 4096 Nov  6 01:37 secret_dir
~/codyssey/practice$ stat -c "%A  %a  %n" secret_dir
drwxr-xr-x  755  secret_dir
~/codyssey/practice$ chmod 644 secret_dir
~/codyssey/practice$ ls -ld secret_dir
drw-r--r-- 2 hunhun345 hunhun345 4096 Nov  6 01:37 secret_dir
~/codyssey/practice$ cd secret_dir
bash: cd: secret_dir: Permission denied
[종료 코드: 1]
~/codyssey/practice$ cat secret_dir/inside.txt
cat: secret_dir/inside.txt: Permission denied
[종료 코드: 1]
~/codyssey/practice$ ls -l secret_dir
total 0
-????????? ? ? ? ?            ? inside.txt
~/codyssey/practice$ chmod 700 secret_dir
~/codyssey/practice$ ls -ld secret_dir
drwx------ 2 hunhun345 hunhun345 4096 Nov  6 01:37 secret_dir
~/codyssey/practice$ cat secret_dir/inside.txt
디렉터리 안의 파일
~/codyssey/practice$ chmod 755 secret_dir
~/codyssey/practice$ stat -c "%A  %a  %n" secret_dir
drwxr-xr-x  755  secret_dir
```

| 시점 | 권한 | 결과 |
|---|---|---|
| 생성 직후 | `drwxr-xr-x` (755) | 정상 |
| `chmod 644` 후 | `drw-r--r--` (644) | `cd` 불가, 안의 파일 읽기 불가, `ls -l`은 이름만 보이고 속성은 `?` |
| `chmod 700` 후 | `drwx------` (700) | 소유자만 진입·읽기·쓰기 가능 (다른 사용자는 접근 불가) |
| `chmod 755` 복원 | `drwxr-xr-x` (755) | 다시 모두 진입·읽기 가능 |

디렉터리에서 **r**은 목록 보기, **w**는 안에 파일 만들기·지우기, **x**는 안으로 들어가기(경로 통과)를 뜻합니다. 그래서 r은 있어도 x가 없으면 이름만 보이고 파일을 열 수 없습니다.

## 2-3. 실습 정리

```bash
~/codyssey/practice$ rm -r secret_dir hello.sh .hidden_config
~/codyssey/practice$ ls -la
total 8
drwxr-xr-x 2 hunhun345 hunhun345 4096 Nov  6 01:37 .
drwxr-xr-x 5 hunhun345 hunhun345 4096 Nov  6 01:37 ..
```

