# 학습 작업일지: Geth 실행 파일, Go 패키지와 빌드, GCC 설치

- 기록일: 2026-10-18
- 이전 기록: [Geth 시작과 JSON-RPC 입구](2026-10-18-study-log.md)
- 학습 배경: Unity/C# 개발 경험 약 3년. Geth 소스를 읽으며 Go를 익히는 중.
- 중단 이유: VS Code를 종료하고 다시 실행해서 변경된 PATH를 반영하려고 함.

## 이번 세션의 출발점

이전 작업일지를 읽고 `cmd/geth/main.go`부터 공부하려 했다. 터미널의 `geth` 명령이 무엇을 실행하는지 질문하면서, 실행 파일과 소스 코드의 차이 및 Go 빌드 방식부터 정리했다. `main()` 본문을 한 줄씩 읽는 학습은 아직 시작하지 않았다.

## 실행 명령과 HTTP 서버

- `geth`는 실행할 프로그램 이름이다. Windows에서는 실행 파일 `geth.exe`를 찾아 실행한다.
- 셸이 명령을 검색하며, PATH는 실행 파일을 찾을 폴더들의 목록이다. 소스를 clone하는 것만으로 `geth` 명령이 생기지는 않는다.
- PowerShell에서 현재 폴더의 파일을 직접 실행할 때는 `.\geth.exe`처럼 경로를 적는다.
- `geth --http`의 `--http`는 Geth의 HTTP JSON-RPC 서버 기능을 켜는 옵션이다.
- HTTP 자체는 요청과 응답을 주고받는 통신 규칙이다. HTTP 서버는 그 규칙에 따라 요청을 받고 응답하는 프로그램이다.
- `net/http`는 Go의 HTTP 라이브러리다. 옵션을 읽은 Geth가 이 라이브러리를 이용해 서버를 만들고 실행한다.
- 빌드된 Geth를 실행하면 소스 파일 `main.go`를 다시 읽는 것이 아니다. 실행 파일 안에서 Go 초기화(패키지 변수, `init()`)를 마친 뒤 `main()`을 실행한다.

## Go 빌드에서 정리한 핵심

```powershell
# 현재 위치를 소스 저장소 루트로 이동
cd C:\Users\p\Desktop\BlockChain\go-ethereum-study\go-ethereum

# Geth 프로그램을 빌드
go build -o geth.exe ./cmd/geth

# 생성된 실행 파일을 실행해서 버전 확인
.\geth.exe version
```

아래 명령도 같은 기본 이름으로 `geth.exe`를 만든다.

```powershell
go build ./cmd/geth
```

- 빌드 명령은 `geth build`가 아니라 `go build`다.
- `go.exe`는 빌드를 관리하는 도구다. 실제 Go 컴파일러와 링커를 내부에서 호출한다.
- `./cmd/geth`는 빌드할 소스 패키지의 위치다. `.`은 현재 폴더를 뜻한다.
- `-o geth.exe`는 결과 파일 이름과 위치를 지정한다. 경로 없이 이름만 주면 현재 폴더에 만든다.
- `go-ethereum` 폴더에서 위 명령을 실행하면 결과 위치는 `go-ethereum\geth.exe`다. `cmd/geth` 안에 생성되는 것이 아니다.
- 컴파일은 소스를 기계어 코드로 바꾸는 단계다. 링크는 필요한 코드들을 연결하는 단계다. `go build`는 두 단계를 포함해 실행 파일을 만든다.
- Geth의 일부 C 코드에는 C 컴파일러도 사용된다.
- 첫 빌드에서는 필요한 외부 라이브러리를 내려받을 수 있다.

## 파일, 폴더, package main의 관계

사용자가 직접 파일을 열어 `cmd/geth`의 여러 Go 파일 맨 위에 `package main`이 적혀 있음을 확인했다.

- Go는 패키지 단위로 빌드한다. 일반적인 경우 같은 폴더의 Go 소스 파일들이 하나의 패키지를 구성한다.
- `cmd/geth/main.go`, `cmd/geth/config.go` 등은 같은 폴더에 있고 `package main`을 선언해서 같은 패키지에 속한다. 하나의 프로그램 코드를 여러 파일에 나눈 것이다.
- `package`는 각 Go 소스 파일에 필요한 선언이다. 빌드 대상으로 선택하는 표시가 아니라 그 파일의 패키지 소속을 나타낸다.
- 이해 기준: 지정한 폴더의 `.go` 파일들을 기본적으로 함께 빌드하며, 제외 조건을 적용한다.
- `*_test.go`는 일반 `go build`에서 제외된다. `*_linux.go` 같은 운영체제 전용 파일이나 빌드 조건이 적힌 파일도 조건에 따라 제외된다. 그 밖의 Go 빌드 규칙도 있으므로 문자 그대로 모든 `.go` 파일이 항상 포함되는 것은 아니다.
- `cmd/geth` 밖의 `package main`을 이름만 보고 함께 모아서 빌드하지 않는다. 폴더 경로가 다르면 패키지 이름이 같아도 별개다. 예: `cmd/geth`와 `cmd/abigen`.
- 대상 패키지가 `import`로 사용하는 다른 패키지들도 필요한 만큼 빌드한다. 저장소 전체의 모든 Go 파일을 무조건 빌드하는 것은 아니다.
- `main.go`라는 파일 이름 자체는 특별한 시작 조건이 아니다. `package main`은 실행 프로그램을 구성하는 패키지이고, `func main()`이 초기화 후 실행을 시작하는 함수다. 파일 이름을 바꿔도 이 선언들이 유지되면 시작 함수 역할은 같다.
- `cmd/geth`를 지정한 이유는 우리가 실행할 Geth 프로그램의 시작 코드가 그곳에 있기 때문이다. HTTP 서버 구현은 `node` 등 다른 패키지에 있다.

## 실행 클라이언트와 합의 클라이언트

- `go-ethereum`은 실행 클라이언트인 Geth와 관련 도구들의 소스 저장소다.
- Lighthouse, Prysm 같은 완전한 합의 클라이언트는 별도 프로그램이다. 일반적인 이더리움 노드는 실행 클라이언트와 합의 클라이언트를 연결해서 운영한다.
- Geth 안에도 합의 관련 검증·통신 코드 및 제한된 비콘 라이트 클라이언트 기능이 있으므로 합의 관련 코드가 전혀 없는 것은 아니다.
- 여기서 클라이언트는 이더리움 네트워크에 참여하는 소프트웨어를 가리킨다. Geth는 실행 클라이언트이면서 지갑의 RPC 요청을 받을 때는 서버 역할도 한다.

## 실제 환경 확인과 설치 결과

### Go

- 이번 대화에서 설치하지 않았다. 확인했을 때 이미 설치되어 있었다.
- 실행 파일: `C:\Program Files\Go\bin\go.exe`
- 확인한 버전: `go version go1.27.0 windows/amd64`
- 언제 설치했는지는 확인하지 않았다.
- 이전 작업일지에서 Go 명령을 찾지 못한 기록은 이전 세션 상태다. 이번 세션에서는 설치와 실행을 확인했다.

### GCC / MinGW-w64

- 사용자 요청에 따라 MSYS2를 설치하고, 그 안에 MinGW-w64용 GCC를 설치했다.
- MSYS2 위치: `C:\msys64`
- 설치한 패키지: `mingw-w64-ucrt-x86_64-gcc` 및 필수 라이브러리.
- GCC 실행 파일: `C:\msys64\ucrt64\bin\gcc.exe`
- 사용자 PATH에 추가한 폴더: `C:\msys64\ucrt64\bin`
- 확인한 버전: `gcc.exe (Rev6, Built by MSYS2 project) 16.2.0`
- 공식 설치 파일의 SHA256을 검증하고 설치했다. 짧은 C 프로그램의 컴파일과 실행도 성공했다.
- MinGW-w64는 Windows 프로그램을 만드는 데 필요한 헤더·라이브러리 등을 제공하며, GCC가 실제 컴파일을 담당한다. MSYS2는 이를 설치·관리하는 환경이다.

### PATH와 터미널 문제

- 기존 터미널에서 `gcc`를 찾지 못했다. 사용자 계정의 PATH 등록과 설치 파일은 정상임을 확인했다.
- 실행 중인 VS Code가 이전 PATH를 유지하면 그 안에서 새 터미널 탭만 열어도 반영되지 않을 수 있다. VS Code를 완전히 종료하고 다시 열기로 했다.
- 독립된 Windows PowerShell에서는 사용자가 직접 `gcc --version`을 실행해 GCC 16.2.0 출력을 확인했다.
- `gcc`만 실행했을 때 나온 `fatal error: no input files`는 프로그램을 실행했지만 컴파일할 파일을 지정하지 않았다는 뜻이다.
- 버전 명령은 `gcc-version`이 아니라 공백과 하이픈 두 개가 있는 `gcc --version`이다.
- 필요하면 현재 터미널에만 경로를 추가하는 방법:

```powershell
$env:Path += ";C:\msys64\ucrt64\bin"
gcc --version
```

## 완료한 작업과 아직 하지 않은 작업

- 완료: 이전 기록 읽기, 로컬 소스 확인, Go 설치 확인, MSYS2/GCC 설치, 사용자 PATH 등록, C 컴파일·실행 확인.
- 사용자 확인: 독립된 PowerShell에서 GCC 버전 출력, 소스 파일의 `package main` 선언 확인.
- 아직: Geth 소스 빌드와 `geth.exe version` 실행 결과 확인. 세션 종료 전 확인했을 때 `go-ethereum\geth.exe`는 없었다.
- Geth 노드 실행, HTTP 서버 시작, 트랜잭션 전송, 체인 동기화는 수행하지 않았다.
- 설명한 내용과 실제 이해를 검증한 내용은 구분한다. 패키지·빌드 개념을 질문으로 정리했지만 추가 확인은 필요하다.

## 다음 세션에서 이어갈 순서

1. 이 작업일지를 먼저 읽는다.
2. VS Code 재실행 후 터미널에서 `go version`, `gcc --version`이 동작하는지 확인한다.
3. `go-ethereum` 폴더에서 `go build ./cmd/geth`를 실행한다. 실패하면 오류 출력부터 살핀다.
4. 성공하면 같은 폴더에서 `.\geth.exe version`으로 실행 파일을 확인한다.
5. [cmd/geth/main.go](../go-ethereum/cmd/geth/main.go)의 `main()`부터 코드 읽기로 돌아간다.
   - `main()`은 287행, `app.Run(os.Args)`는 288행.
   - `app` 생성은 218행, `app.Action = geth`는 222행.
   - 한 번에 전부 설명하지 말고, 먼저 `app`이 무엇인지부터 질문에 맞춰 진행한다.

## 공부 대화 방식

- 한국어로 쉽게, 기본 2~4문장으로 답한다.
- 한 번에 한 개념을 설명하고 사용자의 후속 질문을 기다린다.
- 사용자가 자세히 묻거나 여러 개념을 비교하면 그 범위 안에서 설명을 넓힌다.
- 전문 용어는 쉬운 말로 바로 풀어 설명한다.
- 사용자는 모호한 표현을 꼼꼼하게 되묻는다. 특히 빌드 대상이 어떤 기준으로 정해지는지처럼 선택 기준을 구체적으로 말한다.
- 파일 이름, 함수 이름, 패키지 이름, 폴더 경로를 혼동하지 않도록 분명히 구분한다.

## 참고

- [로컬 빌드 안내](../go-ethereum/README.md)
- [Geth 공식 설치 안내](https://geth.ethereum.org/docs/getting-started/installing-geth)
- [MSYS2 공식 설치 안내](https://www.msys2.org/)
- [Geth와 합의 클라이언트 연결](https://geth.ethereum.org/docs/getting-started/consensus-clients)
