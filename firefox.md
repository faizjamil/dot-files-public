# Firefox notes

## Optimizations

Install [BetterFox](https://github.com/yokoffing/Betterfox) and add the following overrides:

```js

// PREF: revert back to Standard ETP
user_pref("browser.contentblocking.category", "standard");

// PREF: allow embedded tweets and reddit posts [FF136+]
user_pref("urlclassifier.trackingSkipURLs", "embed.reddit.com, *.twitter.com, *.twimg.com"); // MANUAL [FF136+]
user_pref("urlclassifier.features.socialtracking.skipURLs", "*.twitter.com, *.twimg.com"); // MANUAL [FF136+]

// PREF: improve font rendering by using DirectWrite everywhere like Chrome [WINDOWS]
user_pref("gfx.font_rendering.cleartype_params.rendering_mode", 5);
user_pref("gfx.font_rendering.cleartype_params.cleartype_level", 100);
user_pref("gfx.font_rendering.directwrite.use_gdi_table_loading", false);

// PREF: allow websites to ask you for your location
user_pref("permissions.default.geo", 0);

// PREF: restore Top Sites on New Tab page
user_pref("browser.newtabpage.activity-stream.feeds.topsites", true);
// PREF: remove sponsored content on New Tab page
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false); // Sponsored shortcuts 
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false); // Recommended by Pocket
user_pref("browser.newtabpage.activity-stream.showSponsored", false); // Sponsored Stories

// PREF: restore search engine suggestions
user_pref("browser.search.suggest.enabled", true);
// PREF: initial paint delay
// How long FF will wait before rendering the page (in ms)
// [NOTE] You may prefer using 250.
// [NOTE] Dark Reader users may want to use 1000 [3].
// [1] https://bugzilla.mozilla.org/show_bug.cgi?id=1283302
// [2] https://docs.google.com/document/d/1BvCoZzk2_rNZx3u9ESPoFjSADRI0zIPeJRXFLwWXx_4/edit#heading=h.28ki6m8dg30z
// [3] https://old.reddit.com/r/firefox/comments/o0xl1q/reducing_cpu_usage_of_dark_reader_extension/
// [4] https://reddit.com/r/browsers/s/wvNB7UVCpx
user_pref("nglayout.initialpaint.delay", 1000); // DEFAULT; formerly 250
```

## How to make Firefox UI larger

go to `about:config` and modify the `layout.css.devPixelsPerPx` value, default is -1, try a value of either 1.5 or 2
