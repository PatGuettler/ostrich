# Google Play store-listing review fix

Google Play identified the old screenshots as marketing illustrations rather
than the in-app experience. The replacement files in `phone`, `tablet-7`, and
`tablet-10` are direct, uncomposited frames from the running Godot game.

## Play Console steps

1. Open the default English (United States) store listing.
2. Replace the app name, short description, and full description with the text
   in `LISTING.txt`.
3. Delete all six phone screenshots currently uploaded to Play Console. This
   matters: do not leave any of the rejected promotional composites in place.
4. Upload all six files from `phone` in filename order.
5. If tablet listings are active, similarly replace their old images with the
   six files from `tablet-7` and `tablet-10`.
6. Save the listing, review the preview, and send the changes for review.

The app icon and feature graphic are separate promotional asset categories and
can remain. The reported policy problem applies to the screenshot galleries.

## Rebuild the screenshots

From the repository root:

```bash
godot --fixed-fps 60 --path . --script res://tests/art_capture.gd -- --store-listing
python3 scripts/build_play_store_assets.py
```

The first command captures actual rendered game frames into `source-captures`.
The second validates their dimensions and copies them into the upload folders
without crops, added text, blurred backdrops, or promotional composites.
