# 이더리움 실행 클라이언트와 구현 언어

## 대화 중 확인한 내용

동일한 이더리움 규칙을 구현해도 내부 저장 구조·동기화·성능 설계가 다르면 별개의 클라이언트다. 같은 Go로 구현한 Geth와 Erigon도 설정만 다른 동일 프로그램으로 보면 안 된다.

Erigon은 Geth에서 출발했지만 데이터 저장과 동기화 구조를 크게 재설계했다. 공개 노드 관측 비율만으로 실제 서비스에서 거의 사용하지 않는다고 결론 내리지 않는다.

## 비율: 2026-10-17 조회 기록

아래 수치는 당시 [Ethernodes](https://ethernodes.org/) 페이지를 확인한 기록이다. 전체 실제 노드나 검증 지분의 정확한 비율이 아니며, 이후 시점의 최신 비율로 재사용하지 않는다.

| 페이지의 클라이언트 분류 | 언어 | 관측 비율 |
|---|---|---:|
| geth | Go | 40.41% |
| nethermind | C# | 32.84% |
| reth | Rust | 13.31% |
| besu | Java | 7.75% |
| erigon | Go | 1.73% |
| 기타 | 여러 언어 | 3.96% |

기타에는 페이지가 별도로 분류한 go-ethereum 2.05%도 포함했다. 따라서 이 표는 geth 계열 전체를 합산한 통계가 아니다.

[Client Diversity](https://clientdiversity.org/)에서도 공개 피어 관측과 전체 사용 현황 사이에 차이가 있을 수 있음을 설명한다. 구현 언어는 [ethereum.org의 클라이언트 목록](https://ethereum.org/developers/docs/nodes-and-clients/)을 참고했다.

## 학습 선택

- C#에 익숙하므로 Nethermind를 읽으면 언어 문법의 부담은 낮을 수 있다.
- Go도 익히고 싶다는 목적이 있어 현재는 Geth를 계속 읽는 방향으로 대화했다.
- Geth 코드를 보며 당장 필요한 Go 문법만 짧게 배우는 방식을 제안했다.
- 한 언어에 익숙한 것 자체가 편협한 개발자라는 뜻은 아니다.
- 트랜잭션 흐름 학습 중 표준 라이브러리 내부까지 계속 내려가면 목표를 놓칠 수 있으므로 깊이를 조절한다.

## 참고

- [Erigon FAQ](https://docs.erigon.tech/help-center/frequently-asked-questions-faqs)
