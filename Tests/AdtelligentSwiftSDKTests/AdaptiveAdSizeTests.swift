import Testing
import AdtelligentSwiftSDK

struct AdaptiveAdSizeTests {

    // MARK: - Portrait anchored

    @Test func portraitAnchoredClampsBelowNarrowAnchor() {
        let size = AdaptiveAdSize.portraitAnchored(width: 280)
        #expect(size.height == 50)
    }

    @Test func portraitAnchoredClampsAboveWideAnchor() {
        let size = AdaptiveAdSize.portraitAnchored(width: 900)
        #expect(size.height == 90)
    }

    @Test func portraitAnchoredInterpolatesBetweenAnchors() {
        let atWideAnchor = AdaptiveAdSize.portraitAnchored(width: 728)
        #expect(atWideAnchor.height == 90)

        // 524 is the midpoint of 320...728, so height should be the midpoint of 50...90.
        let midpoint = AdaptiveAdSize.portraitAnchored(width: 524)
        #expect(abs(midpoint.height - 70) < 0.01)
    }

    // MARK: - Landscape anchored

    @Test func landscapeAnchoredIsShorterThanPortraitAtSameWidth() {
        let width = 600.0
        let portrait = AdaptiveAdSize.portraitAnchored(width: width)
        let landscape = AdaptiveAdSize.landscapeAnchored(width: width)
        #expect(landscape.height < portrait.height)
    }

    @Test func landscapeAnchoredCompressesTheNarrowAnchorFloor() {
        // anchoredPortraitHeight never goes below 50 (the narrow IAB anchor), so the smallest
        // possible landscape value is 50 * 0.7 = 35 -- above the 32pt floor, which exists as a
        // defensive clamp for constant changes rather than something reachable today.
        let size = AdaptiveAdSize.landscapeAnchored(width: 200)
        #expect(size.height == 35)
    }

    // MARK: - Portrait inline

    @Test func portraitInlineIsAtLeastAnchoredHeight() {
        let width = 375.0
        let anchored = AdaptiveAdSize.portraitAnchored(width: width)
        let inline = AdaptiveAdSize.portraitInline(width: width, maxHeight: 250)
        #expect(inline.height >= anchored.height)
    }

    @Test func portraitInlineClampsToMaxHeight() {
        let size = AdaptiveAdSize.portraitInline(width: 1000, maxHeight: 100)
        #expect(size.height == 100)
    }

    @Test func portraitInlineNeverDropsBelowAnchoredEvenWithLowMaxHeight() {
        let width = 728.0
        let anchored = AdaptiveAdSize.portraitAnchored(width: width)
        let size = AdaptiveAdSize.portraitInline(width: width, maxHeight: 10)
        #expect(size.height == anchored.height)
    }

    // MARK: - Landscape inline

    @Test func landscapeInlineIsAtLeastLandscapeAnchoredHeight() {
        let width = 700.0
        let anchored = AdaptiveAdSize.landscapeAnchored(width: width)
        let inline = AdaptiveAdSize.landscapeInline(width: width, maxHeight: 250)
        #expect(inline.height >= anchored.height)
    }

    @Test func landscapeInlineClampsToMaxHeight() {
        let size = AdaptiveAdSize.landscapeInline(width: 1000, maxHeight: 80)
        #expect(size.height == 80)
    }

    // MARK: - Width passthrough

    @Test func widthIsPassedThroughUnchanged() {
        #expect(AdaptiveAdSize.portraitAnchored(width: 411).width == 411)
        #expect(AdaptiveAdSize.portraitInline(width: 411, maxHeight: 300).width == 411)
    }
}
