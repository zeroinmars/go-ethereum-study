# 작업일지: 개인 공부용 Git 저장소 정리

- 기록일: 2026-11-03
- 목적: Git 관리는 `go-ethereum-study` 한 곳에서 하고, 개인 학습 기록을 독립된 GitHub 저장소에 저장한다.

## 처음 확인한 상태

- 바깥 `go-ethereum-study/`는 커밋과 원격 연결이 없는 Git 저장소였다.
- 안쪽 `go-ethereum/`는 공식 `ethereum/go-ethereum`에서 clone한 별도 Git 저장소였다.
- GitHub 계정 `zeroinmars`에는 공식 저장소의 포크인 `go-ethereum`이 있었다.

## 진행한 작업

1. aside CLI로 GitHub 로그인 계정과 기존 저장소를 확인했다.
2. 처음에는 기존 포크의 `study-notes` 브랜치에 학습 자료 14개를 올렸다. 기존 `master` 이력을 보존하기 위해 임시 worktree를 사용했다.
3. 중첩된 Git 관리를 정리했다. 안쪽 `go-ethereum/.git`을 제거하고 소스 파일은 유지했다. 임시 `go-ethereum-study-publish` 폴더와 로컬 `study-notes` 브랜치도 제거했다.
4. 현재 폴더의 `main`에 학습 자료를 커밋하고 기존 포크에 push했다.
5. 잔디가 표시되지 않는 원인을 확인하면서, 포크에 올린 커밋은 기여 그래프에 집계되지 않는다는 점을 확인했다.
6. aside CLI로 포크가 아닌 공개 저장소 `zeroinmars/go-ethereum-study`를 새로 만들었다.
7. GitHub Settings → Emails에서 계정의 정확한 noreply 이메일을 확인하고, 로컬 작성자 설정과 초기 커밋의 작성자 정보를 수정했다.
8. 현재 폴더의 `origin`을 새 저장소로 변경하고 `main`을 push했다.
9. 새 저장소의 파일, 기본 브랜치, 커밋 및 작성자 계정 연결을 확인한 뒤 기존 `zeroinmars/go-ethereum` 포크를 삭제했다.
10. 이전 포크의 오래된 원격 브랜치 정보를 정리했다.

## 최종 상태

- GitHub: [zeroinmars/go-ethereum-study](https://github.com/zeroinmars/go-ethereum-study)
- 저장소 유형: 공개 독립 저장소, 포크 아님
- 기본 브랜치 및 로컬 브랜치: `main`
- 추적 브랜치: `origin/main`
- 원격 주소: `https://github.com/zeroinmars/go-ethereum-study.git`
- 학습 자료를 이전한 커밋: `361957a6d9e5807e07767bf84a8be8ae8d865b94`
- Git 작성자: `zeroinmars <110643793+zeroinmars@users.noreply.github.com>`
- 로컬 Git 저장소는 바깥 `go-ethereum-study/.git` 하나만 유지한다.
- `go-ethereum/` 소스와 로컬 변경 내용은 보존했다. 이 폴더는 `.gitignore`에 따라 업로드 대상에서 제외된다.
- 기존 포크는 삭제했으며, 공식 `ethereum/go-ethereum`은 변경하지 않았다.

## 검증한 내용

- `git ls-remote`로 새 저장소의 `main`과 로컬 커밋 해시가 일치함을 확인했다.
- 브라우저에서 새 저장소가 포크가 아니고 기본 브랜치가 `main`임을 확인했다.
- `notes/`, `CURRICULUM.md`, `STUDY_GUIDE.md`와 작성자의 GitHub 계정 연결을 확인했다.
- GitHub의 기존 포크 삭제 성공 메시지와 해당 URL의 404를 확인했다.
- `git status`에서 `main`과 `origin/main`이 일치하고 미커밋 변경이 없음을 확인했다. 이 작업일지는 이후 추가한 기록이다.
- 기여 그래프의 실제 반영 여부는 별도로 확인하지 않았다.

## 앞으로 기록 올리기

현재 `go-ethereum-study` 폴더에서 실행한다.

```sh
git add notes CURRICULUM.md STUDY_GUIDE.md
git commit -m "study: update learning notes"
git push
```

소스 코드 자체의 변경도 GitHub에 남기려면, 현재 제외된 `go-ethereum/`의 추적 범위를 별도로 정해야 한다.

## 참고

- clone은 저장소를 로컬에 내려받는 작업이고, fork는 GitHub에서 원본과의 관계를 유지하는 저장소를 만드는 기능이다.
- 기여 그래프 집계에는 독립 저장소의 기본 브랜치와 계정에 연결된 작성자 이메일 등이 영향을 준다.
- [GitHub 기여 내역 누락 안내](https://docs.github.com/en/account-and-profile/how-tos/contribution-settings/troubleshooting-missing-contributions)
