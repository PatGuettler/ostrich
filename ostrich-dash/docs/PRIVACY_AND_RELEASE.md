# Ostrich Dash privacy and release links

Ostrich Dash reuses the public Grapegames privacy site already used by Peregrine.

## Public URLs

- Play Console privacy policy: `https://patguettler.github.io/privacy-policy.html`
- Play Console data-deletion URL: `https://patguettler.github.io/privacy-policy.html#data-deletion`
- Play Console developer website: `https://patguettler.github.io`
- AdMob `app-ads.txt`: `https://patguettler.github.io/app-ads.txt`

The editable site source is in `/home/pat/dev/patguettler.github.io`. Updating that local repository does not change the public page until its change is committed and pushed to the GitHub Pages branch.

## Why the shared policy fits this build

The current game:

- stores progress, settings, unlocks, scores, and earned currency locally through Godot's `user://` storage;
- does not provide a Grapegames account or send save data to a Grapegames server;
- does not include a Grapegames analytics or crash-reporting backend; and
- can use Google Play and Google AdMob on mobile builds.

These are the practices described by the shared policy. Recheck and update the policy and store disclosures before adding accounts, cloud saves, analytics, crash reporting, location, contacts, purchases, or another advertising/SDK provider.

## Release checklist

1. Keep the in-game **Privacy & Data** button working.
2. Put the privacy-policy and data-deletion URLs above into the Play Console listing.
3. Set the listing's developer website to `https://patguettler.github.io` so AdMob can discover the root `app-ads.txt` file.
4. Complete Play Console **Data safety**, **Contains ads**, audience, and content-rating declarations from the behavior of the final release build.
5. Use Google test ad units during development; configure Ostrich Dash-specific production units only for release.
