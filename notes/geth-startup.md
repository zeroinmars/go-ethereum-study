# Geth의 생성과 시작

## 오늘의 질문

`h.start()`를 호출하려면 먼저 `h`가 있어야 한다. 그 인스턴스는 언제 만들어지고 프로그램은 어디서 시작되는가?

## 찾아본 코드

- [cmd/geth/main.go](../go-ethereum/cmd/geth/main.go): `init()`, `main()`, `geth()`, `startNode()`
- [cmd/geth/config.go](../go-ethereum/cmd/geth/config.go): `makeFullNode()`, `makeConfigNode()`
- [cmd/utils/cmd.go](../go-ethereum/cmd/utils/cmd.go): `StartNode()`
- [node/node.go](../go-ethereum/node/node.go): `New()`, `Start()`, `openEndpoints()`, `startRPC()`
- [node/rpcstack.go](../go-ethereum/node/rpcstack.go): `newHTTPServer()`, `httpServer.start()`
- [eth/backend.go](../go-ethereum/eth/backend.go): `New()`, `Ethereum.Start()`

## 정리한 내용

`geth --http`는 컴파일된 실행 파일을 실행하는 예시 명령이다. 이 세션에서 실제로 실행하지 않았다.

Go는 패키지 변수와 `init()` 초기화를 거친 뒤 `main` 패키지의 `main()`을 실행한다. 파일 이름 자체가 실행 순서를 정하는 것은 아니다.

아래는 중간 호출과 오류 처리를 생략한 흐름이다.

```text
실행 파일 geth
  → Go 초기화
  → cmd/geth/main.go: main()
  → app.Run(os.Args)
  → 기본 동작으로 등록된 geth()
      ├─ makeFullNode()
      │    → makeConfigNode()
      │      → node.New()
      │        → newHTTPServer()
      │          → httpServer 인스턴스 생성, node.http에 보관
      └─ startNode()
           → utils.StartNode()
           → Node.Start()
           → openEndpoints()
           → startRPC()
           → HTTP 설정이 활성화된 서버의 start()
```

`init()`에서 `app.Action = geth`로 기본 동작을 지정한다. `version` 같은 별도 하위 명령은 다른 동작을 실행할 수 있다.

`newHTTPServer()`는 일반 함수다. 내부의 `&httpServer{...}`로 객체를 만들어 반환한다. 이후 메서드가 호출될 때 그 객체를 함수 안에서 부르는 이름이 리시버 `h`다.

`httpServer.start()`의 핵심 준비 순서:

```go
h.server = &http.Server{Handler: h}
listener, err := net.Listen("tcp", h.endpoint)
// 오류 처리 생략
go h.server.Serve(listener)
```

- `Handler: h`: 요청 처리 대상으로 Geth의 h를 지정한다.
- `listener`: 지정된 주소·포트로 들어오는 TCP 연결을 받는다.
- `server`: Go 표준 HTTP 서버로, 연결에서 요청을 읽어 등록된 핸들러를 호출한다.
- 실제 HTTP 요청이 들어오면 `net/http`가 응답용 w와 요청 r을 준비해 `h.ServeHTTP(w, r)`로 전달한다.

## DB와 동기화

`makeFullNode()`는 실행 준비 과정이다. Ethereum 서비스 생성 과정에서 `chaindata` DB를 열거나 생성하므로 디스크 작업이 전혀 없는 단계는 아니다.

네트워크에서 대량의 체인 데이터를 받는 동기화는 노드를 시작하고 필요한 연결이 갖춰진 뒤 진행된다. 메인넷 Geth에는 합의 클라이언트 연동도 필요하다. 저장 범위는 동기화·히스토리·가지치기 설정에 따라 달라지며, 모든 과거 상태를 보관하는 아카이브 구성과 구분한다.

## 남은 질문

- [ ] main → app.Run → geth를 코드 한 줄씩 읽기.
- [ ] Node.Start에서 HTTP 서버와 Ethereum 서비스의 시작 순서 확인.
- [ ] 현재 로컬 환경에서 Go 실행 경로 확인.
- [ ] 실제 노드 실행은 별도 학습으로 진행. 이번 기록은 실행 결과가 아닌 코드 분석이다.
