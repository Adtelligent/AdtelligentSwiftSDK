# Adtelligent Swift SDK for iOS

Binary iOS SDK for integrating Adtelligent In-App Ads into your application. Supports banner and full-screen interstitial placements, VAST/outstream video, and a rich event system — with first-class SwiftUI and UIKit APIs.

---

## Requirements

- iOS 14.5+
- Xcode 15.3+
- Swift 5.9+

---

## Installation (Swift Package Manager)

### Option 1 — Xcode UI

1. Open your project in Xcode.
2. Go to **File → Add Packages...**
3. Enter the repository URL:

```
https://github.com/Adtelligent/AdtelligentSwiftSDK
```

4. Choose **Up to Next Major Version**.
5. Select the latest available version.
6. Add the package to your app target.

### Option 2 — Package.swift

```swift
dependencies: [
    .package(
        url: "https://github.com/Adtelligent/AdtelligentSwiftSDK",
        from: "1.0.0"
    )
]
```

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "AdtelligentSwiftSDK", package: "AdtelligentSwiftSDK")
    ]
)
```

---

## SDK Version

`AdtelligentSDK.version` reports the linked SDK's release version at runtime (e.g. `"0.2.2"`) —
useful for logging or support requests:

```swift
import AdtelligentSwiftSDK

print(AdtelligentSDK.version)
```

---

## Privacy & Permissions

### App Transport Security

Add the following to your `Info.plist` to allow ad network traffic:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### App Tracking Transparency (ATT)

The SDK reads the IDFA automatically when ATT is authorized. Add a usage description to your `Info.plist`:

```xml
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads.</string>
```

Request authorization before loading ads, or pass `DefaultIDFAProvider(requestPermissionsOnLoad: true)` when constructing an `AdRequest` to let the SDK request authorization automatically during the first load.

### Location (optional)

If your app already has location permission, the SDK appends GPS coordinates to ad requests automatically — no extra configuration required. The SDK never requests location permission on its own.

---

## Architecture Overview

```
Configuration          — targeting signals (aid, app info, geo, privacy, video, …)
    └── AdRequest                     — bundles a Configuration for a banner/display placement
    └── InterstitialAdRequest         — bundles a Configuration for an interstitial placement
    └── RewardedAdRequest             — bundles a Configuration for a rewarded placement
    └── RewardedInterstitialAdRequest — bundles a Configuration for a rewarded interstitial placement

AdSize                  — banner size, set once up front (fixed IAB constants or an adaptive
                           factory); passed to BannerAdController/UIBannerAdView at construction

SwiftUI API
    BannerAdController — takes an AdSize + showsCloseButton; manages request queueing and view
                          lifecycle
    BannerAdView       — SwiftUI view that hosts the ad WebView

UIKit API
    UIBannerAdView     — takes an AdSize + showsCloseButton; UIView subclass; async/await load

Full-screen (interstitial / rewarded / rewarded interstitial)
    InterstitialAd           — async static factory; no reward
    RewardedAd               — async static factory; grants a reward on completion
    RewardedInterstitialAd   — async static factory; grants a reward, meant for natural app
                                transitions (your app supplies its own intro/skip screen)
    FullScreenAdDelegate     — shared presentation-lifecycle callbacks
    RewardedAdDelegate       — FullScreenAdDelegate + didEarnReward, used by the two reward formats
```

---

## Configuration

`Configuration` groups all targeting and context signals for a single placement. Only `aid` is required; every other field is optional and overrides the SDK's auto-detected value.

```swift
let config = Configuration(
    aid: "12345",
    app: AppInfo(appName: "My App", appBundle: "com.example.myapp"),
    privacy: PrivacyInfo(gdpr: 1, gdprConsent: "<base64 TCString>")
)
```

Ad size is **not** part of `Configuration` — it's set separately via `AdSize` (see
[Banner Sizing](#banner-sizing-adsize) below).

The SDK auto-populates:
- `appName`, `appBundle`, `appVersion` — from `Bundle.main`
- `deviceModel`, `deviceOS`, `deviceOSV`, `deviceLang` — from `UIDevice` and `Locale`
- `geoLat`, `geoLon` — from Core Location when permission is granted
- `idfa` — from `ATTrackingManager` when ATT is authorized

Explicitly provided values always take precedence over auto-detected ones.

### Configuration Sub-structs

| Sub-struct | Purpose |
|---|---|
| `RequestInfo` | User-agent, cache-buster, CPM floor, ad duration |
| `AppInfo` | App name, bundle ID, Store URL, domain, version |
| `Identifiers` | IDFA, IDFV, ADID and their hashed variants |
| `GeoInfo` | Lat/lon, country, city, ZIP, DMA |
| `DeviceInfo` | Model, make, OS, language, connection type |
| `AdInfo` | Ad position, media type, slot ID, brand-safety rating |
| `PrivacyInfo` | GDPR, CCPA/USPrivacy, COPPA, ATT status, GPP, schain |
| `VideoInfo` | Mute, autoplay, skip settings, MIME type, playback method |
| `ContentInfo` | Title, series, episode, category, keywords, channel |
| `PodInfo` | Pod duration and slot limits for multi-ad video breaks |

---

## Requests

### AdRequest — Banner / Display

```swift
// Minimal
let request = AdRequest(configuration: Configuration(aid: "12345"))

// With targeting overrides
let request = AdRequest(
    configuration: Configuration(
        aid: "12345",
        privacy: PrivacyInfo(gdpr: 0)
    )
)
```

Pass the request to `BannerAdController.loadAd(request:)` (SwiftUI) or `UIBannerAdView.loadAd(request:)` (UIKit).

---

## Banner Sizing (`AdSize`)

Banner size is set once, up front, via `AdSize` — not through `Configuration`. Pass it when
constructing a `BannerAdController` (SwiftUI) or `UIBannerAdView` (UIKit):

```swift
// Fixed IAB sizes
AdSize.standardBanner    // 320×50
AdSize.mediumRectangle   // 300×250
AdSize.leaderboard       // 728×90

// Arbitrary fixed size
AdSize(width: 320, height: 50)

// Adaptive — computed from the available width
AdSize.portraitAnchored(width: 393)
AdSize.landscapeAnchored(width: 852)
AdSize.currentOrientationAnchored(width: 393)          // @MainActor

AdSize.portraitInline(width: 393, maxHeight: 250)
AdSize.landscapeInline(width: 852, maxHeight: 250)
AdSize.currentOrientationInline(width: 393, maxHeight: 250)   // @MainActor
```

### Resizing

Call `updateAdSize(_:)` on either type to resize an existing banner. If an ad is already loaded,
this automatically re-requests it at the new size — no need to build a new `AdRequest` or call
`loadAd(request:)` again yourself:

```swift
controller.updateAdSize(.landscapeAnchored(width: newWidth))   // SwiftUI
bannerView.updateAdSize(.landscapeAnchored(width: newWidth))   // UIKit
```

### InterstitialAdRequest / RewardedAdRequest / RewardedInterstitialAdRequest — Full-screen

```swift
let request = InterstitialAdRequest(configuration: Configuration(aid: "12345"))

// Optional: pre-fetch the ad payload before showing it
try await request.load()
```

`RewardedAdRequest` and `RewardedInterstitialAdRequest` work identically — same `load()`, same
automatic sizing — see [Full-Screen Ads](#full-screen-ads) below for the reward-specific pieces.
Screen dimensions are determined automatically from the active key window in all three. Pass the
request to `InterstitialAd.load(request:)` / `RewardedAd.load(request:reward:)` /
`RewardedInterstitialAd.load(request:reward:)`.

---

## Banner Ads

### SwiftUI

Use `BannerAdView` with a `BannerAdController`. The controller handles request queueing: if `loadAd` is called before the SwiftUI view has appeared, the request is stored and dispatched automatically once the view initializes.

```swift
import AdtelligentSwiftSDK
import SwiftUI

struct ContentView: View {
    @State private var controller: BannerAdController? = BannerAdController(adSize: .standardBanner)

    var body: some View {
        VStack {
            if let controller {
                BannerAdView(controller: controller) {
                    // Called when the ad closes — update your state here
                    self.controller = nil
                }
            }
        }
        .onAppear {
            let request = AdRequest(configuration: Configuration(aid: "12345"))
            controller?.loadAd(request: request)
        }
    }
}
```

#### Receiving callbacks (SwiftUI)

Implement `BannerAdViewDelegate` and set it on the controller before loading:

```swift
class MyAdDelegate: BannerAdViewDelegate {
    func bannerAdDidLoad(aid: String) {
        print("Ad loaded for placement \(aid)")
    }

    func bannerAd(aid: String, didFailWithError error: Error) {
        print("Ad failed: \(error.localizedDescription)")
    }

    func bannerAd(aid: String, didReceiveEvent event: Event, userInfo: [String: Any]?) {
        print("Event: \(event.rawValue)")
    }

    func bannerAd(aid: String, didReceivePlayerError message: String) {
        print("Player error: \(message)")
    }
}

let delegate = MyAdDelegate()
controller.delegate = delegate
```

#### Close button

Banners show a built-in close button by default. Pass `showsCloseButton: false` to hide it (e.g.
if you render your own dismiss UI), or toggle it at any time — it's a UI-only change and never
requires reloading the ad:

```swift
let controller = BannerAdController(adSize: .standardBanner, showsCloseButton: false)
controller.showsCloseButton = true   // can be flipped later too
```

### UIKit

`UIBannerAdView` exposes an `async throws` API. It sizes itself from `adSize` — constrain its
leading edge and one vertical edge only, and do **not** add an external width/height constraint,
then call `loadAd(request:)`.

```swift
import AdtelligentSwiftSDK
import UIKit

class BannerViewController: UIViewController, UIBannerAdViewDelegate {

    private let bannerView = UIBannerAdView(adSize: .standardBanner)

    override func viewDidLoad() {
        super.viewDidLoad()

        bannerView.delegate = self
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)

        NSLayoutConstraint.activate([
            bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])

        Task {
            do {
                let request = AdRequest(configuration: Configuration(aid: "12345"))
                try await bannerView.loadAd(request: request)
            } catch {
                print("Ad failed to load: \(error.localizedDescription)")
            }
        }
    }

    // MARK: UIBannerAdViewDelegate

    func bannerAdViewDidLoad(_ banner: UIBannerAdView) { }

    func bannerAdView(_ banner: UIBannerAdView, didFailToLoadWithError error: Error) { }

    func bannerAdView(_ banner: UIBannerAdView, didReceiveEvent event: Event, userInfo: [String: Any]?) { }

    func bannerAdView(_ banner: UIBannerAdView, didReceivePlayerError message: String) { }
}
```

`showsCloseButton` works the same way as the SwiftUI controller — pass it at construction or set
`bannerView.showsCloseButton` at any time:

```swift
let bannerView = UIBannerAdView(adSize: .standardBanner, showsCloseButton: false)
```

---

## Full-Screen Ads

Three formats share the same load-then-`present(from:)` pattern and delegate protocols. The ad
dismisses itself automatically on `Event.close`.

| Type | Reward? | Presented when |
|---|---|---|
| `InterstitialAd` | No | Natural app transitions (level end, screen change, …) |
| `RewardedAd` | Yes | Only after the user explicitly opts in via your own UI (e.g. "Watch an ad to earn 50 coins?") |
| `RewardedInterstitialAd` | Yes | Natural app transitions — **your app must show its own intro screen with reward messaging and a skip option** before presenting |

### Interstitial

Load the ad in the background and present it at the right moment:

```swift
import AdtelligentSwiftSDK

class MyViewController: UIViewController, FullScreenAdDelegate {

    private var interstitialAd: InterstitialAd?

    func preloadAd() {
        Task {
            do {
                let request = InterstitialAdRequest(configuration: Configuration(aid: "12345"))
                let ad = try await InterstitialAd.load(request: request)
                ad.delegate = self
                self.interstitialAd = ad
            } catch {
                print("Interstitial failed to load: \(error.localizedDescription)")
            }
        }
    }

    func showAd() {
        interstitialAd?.present(from: self)
    }

    // MARK: FullScreenAdDelegate

    func adDidDismiss(_ ad: any FullScreenAd) {
        interstitialAd = nil
    }

    func ad(_ ad: any FullScreenAd, didFailToPresentWithError error: Error) {
        print("Presentation failed: \(error.localizedDescription)")
    }
}
```

**`present(from:)`** resolves to the topmost presented view controller automatically. Pass `nil`
to use the active key-window root.

You can also pre-fetch the payload separately and pass the request to `InterstitialAd.load`:

```swift
let request = InterstitialAdRequest(configuration: Configuration(aid: "12345"))
try await request.load()   // pre-fetch now
// … later …
let ad = try await InterstitialAd.load(request: request)  // reuses cached payload
ad.present(from: nil)
```

### Rewarded

Present only after the user explicitly opts in via your own UI:

```swift
import AdtelligentSwiftSDK

class MyViewController: UIViewController, RewardedAdDelegate {

    private var rewardedAd: RewardedAd?

    func preloadAd() {
        Task {
            do {
                let request = RewardedAdRequest(configuration: Configuration(aid: "12345"))
                let ad = try await RewardedAd.load(request: request, reward: Reward(type: "coins", amount: 50))
                ad.delegate = self
                self.rewardedAd = ad
            } catch {
                print("Rewarded ad failed to load: \(error.localizedDescription)")
            }
        }
    }

    func showAd() {
        rewardedAd?.present(from: self)
    }

    // MARK: RewardedAdDelegate

    func ad(_ ad: any FullScreenAd, didEarnReward reward: any Rewardable) {
        guard let reward = reward as? Reward else { return }
        grantCurrency(amount: reward.amount)
    }

    func adDidDismiss(_ ad: any FullScreenAd) {
        rewardedAd = nil
    }
}
```

`didEarnReward` fires exactly once, when the video plays to completion — not if the user closes
or skips early, and always before `adDidDismiss` if it fires at all. `Reward` is a ready-made
`{type, amount}` conformer to `Rewardable`; conform your own type instead if you need something
richer.

### Rewarded Interstitial

Same loading/presentation API as `RewardedAd`, but meant to be shown automatically at natural app
transitions rather than after explicit opt-in. **This SDK does not render an intro/consent
screen** — show your own (reward messaging + a skip option) before calling `present(from:)`:

```swift
let request = RewardedInterstitialAdRequest(configuration: Configuration(aid: "12345"))
let ad = try await RewardedInterstitialAd.load(request: request, reward: Reward(type: "coins", amount: 50))
// ... show your own intro screen, then, if the user doesn't skip:
ad.delegate = self   // RewardedAdDelegate
ad.present(from: self)
```

### FullScreenAdDelegate / RewardedAdDelegate

All three formats share `FullScreenAdDelegate`. `RewardedAd`/`RewardedInterstitialAd` use
`RewardedAdDelegate`, which adds `didEarnReward` on top. Every method except
`ad(_:didReceiveEvent:userInfo:)` and `ad(_:didReceivePlayerError:)` has a default no-op
implementation, so implement only what you need. Load success/failure isn't delivered here — it's
already covered by the throwing async factory (`try await X.load(request:)`).

| Method | When |
|---|---|
| `adWillPresent(_:)` | Immediately before the ad is presented |
| `adWillDismiss(_:)` | Immediately before the ad is dismissed |
| `adDidDismiss(_:)` | After dismissal has finished |
| `adDidRecordImpression(_:)` | An impression is recorded |
| `adDidRecordClick(_:)` | The user clicks the ad |
| `ad(_:didFailToPresentWithError:)` | Presentation fails (already presenting, or no suitable view controller available) |
| `ad(_:didReceiveEvent:userInfo:)` | Any lifecycle event fires — `.close` arrives here as dismissal *begins*, before `adDidDismiss(_:)` |
| `ad(_:didReceivePlayerError:)` | The video player hits a runtime error |
| `ad(_:didEarnReward:)` *(RewardedAdDelegate only)* | The reward is earned (video played to completion) |

---

## Events

`Event` is an enum whose `rawValue` matches the event name sent from the ad's JavaScript layer.

### Common events

| Event | Description |
|---|---|
| `.noAds` | Server returned no fill for this placement |
| `.campaignReceived` | A campaign was fetched and is ready to render |
| `.campaignUserClick` | User tapped a campaign click target; URL opened automatically |
| `.swipeSlider` | User swiped to a different slide in a carousel ad |
| `.slideClick` | User tapped a slide in a carousel ad; URL opened automatically |
| `.close` | Ad requested dismissal; the containing view is removed automatically |

### Video events

| Event | Description |
|---|---|
| `.videoLoaded` | Ad creative loaded and ready to play |
| `.videoStarted` | Playback began |
| `.videoPaused` / `.videoResumed` | Pause/resume |
| `.videoComplete` | Played to the end |
| `.videoSkipped` | User skipped the ad |
| `.videoError` | Player runtime error (`userInfo[Event.UserInfoKey.data]` has the message) |
| `.videoImpression` | Impression recorded |
| `.videoFirstQuartile` / `.videoMidpoint` / `.videoThirdQuartile` | Progress milestones |
| `.videoMute` / `.videoUnmute` | Volume toggle |
| `.videoClickthrough` | User clicked through the ad |

### UserInfo keys

```swift
// aid is always present
let aid = userInfo?[Event.UserInfoKey.aid] as? String

// present for swipeSlider and slideClick
let index = userInfo?[Event.UserInfoKey.index] as? Int

// present for campaignReceived and campaignUserClick
let campaignID = userInfo?[Event.UserInfoKey.campaignID] as? Int64
let sourceID   = userInfo?[Event.UserInfoKey.sourceID]   as? Int64

// present for campaignUserClick and slideClick
let clickURL = userInfo?[Event.UserInfoKey.clickURL] as? String

// present for events that carry a player payload (e.g. videoError)
let data = userInfo?[Event.UserInfoKey.data] as? String
```

---

## NotificationCenter

Every delegate callback is also broadcast via `NotificationCenter` on the main thread. This is useful for modules that don't hold a reference to the ad view.

```swift
NotificationCenter.default.addObserver(
    forName: .adtelligentCampaignReceived,
    object: nil,
    queue: .main
) { notification in
    let campaignID = notification.userInfo?[Event.UserInfoKey.campaignID] as? Int64
}
```

| Notification.Name | Corresponding Event |
|---|---|
| `.adtelligentNoAds` | `.noAds` |
| `.adtelligentSwipeSlider` | `.swipeSlider` |
| `.adtelligentCampaignReceived` | `.campaignReceived` |
| `.adtelligentCampaignUserClick` | `.campaignUserClick` |
| `.adtelligentSlideClick` | `.slideClick` |
| `.adtelligentClose` | `.close` |

---

## Error Handling

All throwing methods surface `AdtelligentError`:

| Case | Meaning |
|---|---|
| `.adtelligentError(String)` | Server returned an error message |
| `.vastError(String)` | VAST response contained a `<ServerError>` element |
| `.invalidResponse` | Unexpected HTTP status or missing body |
| `.invalidData` | Response body could not be parsed |
| `.networkUnavailable` | No network connection |
| `.transportError(String)` | URLSession transport error |
| `.configurationError` | SDK component not wired up correctly |
| `.serializationFailed` | JSON encode/decode failure |
| `.unknownError` | No additional context available |
| `.adAlreadyPresenting` | `present(from:)` called again before the previous presentation was dismissed |
| `.presenterUnavailable` | No suitable view controller currently available to present from |

```swift
do {
    let ad = try await InterstitialAd.load(request: request)
    ad.present(from: nil)
} catch AdtelligentError.vastError(let message) {
    print("VAST error: \(message)")
} catch AdtelligentError.networkUnavailable {
    print("No internet connection")
} catch {
    print("Load failed: \(error.localizedDescription)")
}
```

---

## Advanced: Custom IDFA Provider

Implement `IDFAProvider` to substitute a test double during unit tests or to supply a custom ATT flow:

```swift
class TestIDFAProvider: IDFAProvider {
    var requestPermissionsOnLoad: Bool { false }
    var canRequestTrackingAuthorization: Bool { false }
    var trackingAuthorizationStatus: ATTrackingManager.AuthorizationStatus { .authorized }

    func isTrackingAccessNotDetermined() -> Bool { false }
    func isTrackingAccessAvailable() -> Bool { true }

    func requestTrackingAuthorization(completionHandler: @escaping @Sendable (ATTrackingManager.AuthorizationStatus) -> Void) {
        completionHandler(.authorized)
    }

    @discardableResult
    func requestTrackingAuthorization() async -> ATTrackingManager.AuthorizationStatus { .authorized }

    func idfa() -> String? { "00000000-0000-0000-0000-000000000000" }
}

let request = AdRequest(
    configuration: Configuration(aid: "12345"),
    idfaProvider: TestIDFAProvider()
)
```
