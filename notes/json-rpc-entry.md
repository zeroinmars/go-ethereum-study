# JSON-RPC 요청은 어디로 들어오는가

## 찾아본 코드

- [node/rpcstack.go](../go-ethereum/node/rpcstack.go): `httpServer`, `ServeHTTP()`, `enableRPC()`, `RegisterApis()`
- [node/node.go](../go-ethereum/node/node.go): `RegisterHandler()`
- [rpc/http.go](../go-ethereum/rpc/http.go): `Server.ServeHTTP()`
- [rpc/server.go](../go-ethereum/rpc/server.go): `serveSingleRequest()`
- [rpc/handler.go](../go-ethereum/rpc/handler.go): `handleCall()`, `runMethod()`
- [rpc/service.go](../go-ethereum/rpc/service.go): 메서드 등록·조회·reflection 호출
- [internal/ethapi/api.go](../go-ethereum/internal/ethapi/api.go): `SendRawTransaction()`, `SubmitTransaction()`
- [eth/api_backend.go](../go-ethereum/eth/api_backend.go): `SendTx()`

## 요청 경로

중간 래퍼·호출을 생략한 HTTP 단일 요청의 흐름이다.

```text
지갑 / 백엔드 / curl 등
  → HTTP JSON-RPC
  → node.httpServer.ServeHTTP()
  → rpc.Server.ServeHTTP()
  → serveSingleRequest(): JSON-RPC 메시지 읽기
  → handleCall(): method 조회, params 변환
  → 등록된 콜백을 reflection으로 호출
  → TransactionAPI.SendRawTransaction()
  → SubmitTransaction()
  → EthAPIBackend.SendTx()
  → txPool.Add()
```

다른 노드가 P2P로 전파하는 트랜잭션은 이 HTTP 경로와 별개다. 지갑인지 다른 프로그램인지보다 어떤 통신 경로를 쓰는지가 기준이다.

`SendRawTransaction()`은 서명된 바이트를 `types.Transaction`으로 디코딩한다. 형식만 맞으면 되는 것이 아니라 서명·잔액·nonce 등 관련 검증을 통과해야 하며, 제출했다고 블록 포함이 보장되지는 않는다.

## w와 r

- `r *http.Request`: HTTP 요청 정보를 담고, `r.Body`로 본문을 읽는다.
- `w http.ResponseWriter`: 응답을 작성해 보내는 인터페이스다. 클라이언트가 보내온 객체가 아니다.
- 실제 데이터는 네트워크 바이트로 들어온다. `net/http`가 서버 내부에서 사용할 객체를 준비한다.
- Geth가 `http.Server{Handler: h}`로 처리 대상을 지정했기 때문에 h의 ServeHTTP가 호출된다.

## httpServer의 필드

| 필드 | 역할 |
|---|---|
| httpConfig | 공개 모듈·경로·CORS 등 HTTP RPC 설정 |
| server | 실제 HTTP 처리를 담당하는 표준 라이브러리 서버 |
| listener | 주소·포트로 들어오는 TCP 연결을 받는 객체 |
| mux | URL 경로에 맞는 핸들러를 찾는 라우터 |
| mu | 서버 내부 상태 변경을 보호하는 잠금 |
| handlerNames | 등록된 경로 → 표시 이름을 저장하는 map |

`httpConfig.Modules`에는 `[]string{"eth", "net", "web3"}`처럼 RPC 네임스페이스를 넣는다. `eth_sendRawTransaction`은 eth 그룹의 메서드다. 개별 메서드 이름을 넣는 필드는 아니다.

`Node.RegisterHandler()`는 내부에서 `n.http.mux.Handle(path, handler)`로 경로를 등록한다. ServeHTTP에서는 등록된 경로를 먼저 확인하고, 없으면 RPC 경로를 확인한다. mux가 JSON 본문의 eth 메서드를 고르는 것은 아니다.

ServeMux의 내부 필드:

- tree: 경로와 핸들러 연결을 저장·검색한다.
- index: 등록할 패턴의 충돌 검사에 사용한다.
- mu: 내부 자료 접근을 보호한다.
- mux121: Go 1.21 동작과의 호환용 구현이다.

HandleFunc은 경로와 처리 함수를 등록하는 메서드다. 두 번째 인자의 이름 없는 함수는 등록할 처리 코드이며, 익명 함수라는 사실 자체가 비동기를 뜻하지 않는다.

## 지갑에서 회사 Geth로 보내기

```text
외부 사용자 지갑 → 공개 RPC 주소 → 회사 Geth
```

- `127.0.0.1`은 요청하는 기기 자신이다. 같은 PC의 지갑과 Geth 연결에 사용할 수 있다.
- 다른 기기는 접속 가능한 서버 주소가 필요하고, 서버 측 수신·네트워크 설정도 맞아야 한다.
- 메타마스크는 기본 연결 제공자로 Infura를 사용하지만, Infura는 필수가 아니다. 다른 지갑도 모두 같다고 단정하지 않는다.
- 지갑이 직접 전송하는 방식에서는 지갑이 선택한 RPC 설정이 중요하다.
- 서비스 사이트 접속이나 지갑 연결만으로 사용자 지갑의 전송 RPC가 자동으로 내 주소로 바뀌지는 않는다.
- 별도의 중계·스마트 계정 구조는 이번 세션에서 다루지 않았다.

## 참고

- [Geth JSON-RPC 서버](https://geth.ethereum.org/docs/interacting-with-geth/rpc)
- [메타마스크의 노드 연결](https://support.metamask.io/more-web3/learn/how-does-metamask-connect-to-a-blockchain-network/)
- [메타마스크 RPC 설정](https://support.metamask.io/configure/networks/how-to-add-a-custom-network-rpc)
- [Go ServeMux](https://go.dev/src/net/http/server.go)
