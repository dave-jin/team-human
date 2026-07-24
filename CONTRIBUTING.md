# 함께 작업하기

Team Human 홈페이지(withteamhuman.com) 저장소입니다. 빌드 도구 없는 순수 HTML/CSS/JS라 별도 설치가 필요 없습니다.

## 시작하기

**포크하지 말고 이 저장소를 그대로 clone 하세요.**

```bash
git clone https://github.com/dave-jin/team-human.git
cd team-human
```

포크에서 올린 PR은 GitHub 보안 정책상 저장소 시크릿을 읽을 수 없어 **프리뷰 배포가 동작하지 않습니다.** 우회 방법이 없는 GitHub의 경계라, 협업자에게는 write 권한을 드려 브랜치로 작업하시게 합니다.

로컬에서 볼 때는 아무 정적 서버나 쓰면 됩니다:

```bash
python3 -m http.server 8000
# http://localhost:8000
```

`file://`로 직접 열면 `i18n/*.json` fetch가 CORS로 막혀 번역이 안 뜨니 반드시 서버로 띄우세요.

## 작업 흐름

```bash
git switch -c 이름/무엇을-바꾸는지     # 예: rachel/team-photo-update
# ...수정...
git commit
git push -u origin 이름/무엇을-바꾸는지
gh pr create        # 또는 GitHub 웹에서 PR 생성
```

PR을 열면 **GitHub Actions가 자동으로 프리뷰를 배포하고 URL을 코멘트로 남깁니다.** 로그인 없이 바로 열립니다. 푸시할 때마다 같은 코멘트가 갱신됩니다.

`main`에 직접 푸시하지 마세요. 리뷰가 끝나고 PR이 머지되면 그때 프로덕션(withteamhuman.com)에 자동 배포됩니다.

## 무엇을 고칠 때 어디를 건드리는지

`CLAUDE.md`에 전체 규칙이 있습니다. 자주 헷갈리는 것만 옮기면:

- **문구 수정** — 화면에 보이는 글자는 HTML이 아니라 `i18n/en.json`과 `i18n/ko.json`에 있습니다. **두 파일 다** 고쳐야 합니다. HTML의 글자는 JS가 꺼졌을 때만 보이는 대체 텍스트입니다.
- **팀원 추가·수정** — `index.html`(카드 마크업) + `i18n/en.json` + `i18n/ko.json` 세 곳.
- **이벤트 추가** — `events.html` + 양쪽 i18n. 이미지는 `images/Event/`에 `YYMMDD슬러그.png` 형식으로.
- **디자인 목업** — `team-human-design.pen`이 실제 사이트의 거울입니다. 팀원·이벤트·색상·폰트를 바꿨다면 **같은 커밋에서** 이 파일도 맞춰 주세요. 규칙은 `CLAUDE.md`의 "Design ↔ Code Sync" 항목에 있습니다.
- **`/guide` 페이지** — 한국어 전용이라 i18n을 쓰지 않습니다. 여기에 영어를 섞지 마세요.

## 배포가 어떻게 돌아가는지

Vercel의 Git 연동이 아니라 **GitHub Actions**가 배포합니다.

- **PR** → `.github/workflows/preview.yml` → 프리뷰 URL을 PR에 코멘트
- **main 머지** → `.github/workflows/deploy.yml` → withteamhuman.com

이렇게 하는 이유: Vercel 계정이 1인 요금제(Hobby)라, Vercel의 Git 연동은 **커밋 작성자가 계정 멤버가 아니면 배포를 거부**합니다(`TEAM_ACCESS_REQUIRED`). Actions에서 CLI로 올리면 커밋 작성자 정보가 붙지 않아 누가 쓴 커밋이든 배포됩니다.

부작용 하나: Vercel 대시보드의 각 배포에 커밋 메시지·작성자가 표시되지 않습니다. 이력은 GitHub Actions 쪽을 보세요.

배포가 실패하면 PR 하단 체크나 [Actions 탭](https://github.com/dave-jin/team-human/actions)에 빨간 X로 뜹니다. 로그를 열어 확인하고, 토큰 만료처럼 저장소 설정이 원인이면 Dave에게 알려주세요.
