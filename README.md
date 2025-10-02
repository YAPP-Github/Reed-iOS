# Reed
> 문장과 감정을 함께 담는 독서 기록

<div align=center>
<a href="https://apps.apple.com/kr/app/reed/id6747740414" target="_blank"> <img src="https://github.com/user-attachments/assets/cfb6c288-7b66-4488-98c7-df07de27e8a5" alt="Download_on_the_App_Store_Badge" width="150"></a>
<a href="https://play.google.com/store/apps/details?id=com.ninecraft.booket&hl=ko" target="_blank"><img src="https://github.com/user-attachments/assets/76d30e5f-7a9c-4fd3-80fc-6e19395bd20a" alt="Google_Play_Store_badge_EN" width="150"></a><br>
<img width="1024" height="500" alt="reed_graphic" src="https://github.com/user-attachments/assets/357cab12-db36-4de0-8fad-664abc5df8c8" />
</div>

## 🛠 Development Environment
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-16.4-blue.svg)](https://developer.apple.com/xcode/)
[![Tuist](https://img.shields.io/badge/Tuist-4.31.0-green.svg)](https://tuist.io)
[![iOS](https://img.shields.io/badge/iOS-16.0+-black.svg)](https://www.apple.com/ios)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
![CodeRabbit Pull Request Reviews](https://img.shields.io/coderabbit/prs/github/YAPP-Github/Reed-iOS?utm_source=oss&utm_medium=github&utm_campaign=YAPP-Github%2FReed-iOS&labelColor=171717&color=FF570A&link=https%3A%2F%2Fcoderabbit.ai&label=CodeRabbit+Reviews)

## 🎥 Main Features
<table>
  <tr>
    <td align="center">도서 검색</td>
    <td align="center">문장 기록</td>
    <td align="center">OCR</td>
    <td align="center">기록 조회</td>
    <td align="center">문장 카드</td>
  </tr>
  <tr>
    <td>
      <img src="https://github.com/user-attachments/assets/55dd0968-fd9b-4222-ba4a-2e38cd5739d6" width="240">
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/51e66fbb-2c14-4c65-9bc2-a87de8ed1389" width="240">
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/35b121ee-652d-4be0-a29a-e45a5dfcfd7f" width="240">
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/da166b9c-cba8-450f-9970-02601f1c284f" width="240">
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/b5f6b54c-3d25-44ec-be7c-595a30708331" width="240">
    </td>
  </tr>
</table>

## ✏️ Project Design
<img width="886" height="479" alt="스크린샷 2025-09-28 오후 9 11 32" src="https://github.com/user-attachments/assets/ccf557e7-3d97-4482-930a-bd00b5b3ef7a" />

### 📂 Foldering
```markdown
📚 BK Projects
├── 📦 BKCore
│   ├── DIContainer
│   │   └── Interface
│   ├── Extension
│   └── Logger
├── 💾 BKData
│   ├── API
│   ├── DTO
│   │   ├── Request
│   │   └── Response
│   ├── Repository
│   ├── Service
│   └── Error
├── 🎨 BKDesign
│   ├── Components
│   │   ├── Button
│   │   ├── TextField
│   │   ├── BottomSheet
│   │   ├── Dialog
│   │   ├── Label
│   │   └── Chip
│   ├── Foundation
│   │   ├── ColorSystem
│   │   ├── Typography
│   │   └── GraphicSystem
│   └── Resources
│       ├── Assets
│       └── Fonts
├── 🏛️ BKDomain
│   ├── Entity
│   ├── Error
│   ├── Interface
│   │   ├── Repository
│   │   └── UseCase
│   ├── UseCase
│   └── VO
├── 🌐 BKNetwork
│   ├── Provider
│   ├── Adapter
│   ├── Helper
│   └── Extension
├── 📂 BKStorage
│   ├── Storage
│   │   ├── Keychain
│   │   └── UserDefaults
│   └── TokenStorage
├── 🖼️ BKPresentation
│   ├── Common
│   │   ├── Component
│   │   ├── Coordinator
│   │   └── Extension
│   ├── MainFlow
│   │   ├── Home
│   │   ├── BookDetail
│   │   ├── Note
│   │   ├── NoteCompletion
│   │   ├── NoteEdit
│   │   ├── Search
│   │   └── Setting
│   ├── ArchiveFlow
│   ├── AuthFlow
│   │   ├── Login
│   │   └── Terms
│   ├── OnboardingFlow
│   ├── TabBarFlow
│   └── AppCoordinator
└── 📱 Booket (Main App)
    ├── Resources
    └── Sources
```

## 🎁 Library
| Name         | Version  |  Description        |
|:---:|:---:|:---:|
| [SnapKit](https://github.com/SnapKit/SnapKit) | `5.7.1` | Auto Layout 제약조건을 코드로 쉽게 작성 |
| [Kingfisher](https://github.com/onevcat/Kingfisher) | `8.5.0` | 이미지 다운로드 및 캐싱 라이브러리 |
| [Lottie](https://github.com/airbnb/lottie-ios) | `4.5.2` | 애니메이션 렌더링 라이브러리 |
| [KakaoSDK](https://github.com/kakao/kakao-ios-sdk) | `2.23.0` | 카카오 소셜 로그인 |
| [Pulse](https://github.com/kean/Pulse) | `5.1.4` | 네트워크 로깅 및 디버깅 도구 |
| [Firebase](https://github.com/firebase/firebase-ios-sdk) | `12.1.0` | Analytics, Crashlytics, Remote Config |
| [Quick](https://github.com/Quick/Quick) | `7.6.2` | BDD 스타일 테스트 프레임워크 |
| [Nimble](https://github.com/Quick/Nimble) | `13.7.1` | 테스트 매처 라이브러리 |

## 🍎 Developers
| [정지용](https://github.com/clxxrlove) | [김도연](https://github.com/doyeonk429) |
|:---:|:---:|
| <img width="144" src="https://avatars.githubusercontent.com/u/70135292?v=4"> | <img width="144" src="https://avatars.githubusercontent.com/u/80318425?v=4"> |
