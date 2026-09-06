# Team portrait frame

Every photo in `images/PFP/` is `1584 x 672` with the subject on a flat warm-greige
backdrop. The card renders it at `height: 200px; object-fit: cover`, so it also
centre-crops horizontally — **vertical framing is what the visitor sees.**

Photos come from different shoots, so left alone the faces land at wildly
different sizes. Measured before this tool existed, face width ranged from
**157px (Sireal) to 223px (Chloe)** — a 1.42x spread — and the eye line moved
over 56px between cards. In a nine-card grid that reads as sloppiness.

## The house frame

| | |
|---|---|
| canvas | `1584 x 672` |
| face width | **185 px** |
| eye line | **y = 245** |
| face centre | **x = 792** (frame centre) |

Face width, not head or shoulder width — hair volume is a person's own
attribute and should not drive the layout. Aligning the eye line is what makes
a row of portraits read as one set.

## Use

```bash
# fit one new member's photo
swift tools/pfp/fit-portrait.swift ~/somewhere/new-member.png images/PFP/Name.png

# just measure, change nothing
swift tools/pfp/fit-portrait.swift images/PFP/Name.png --measure-only

# re-fit the whole roster (after changing the constants above)
tools/pfp/fit-all.sh
tools/pfp/fit-all.sh --dry-run
```

Needs macOS with the Xcode command line tools — it uses Vision for face
detection and CoreGraphics to render. No other dependency, and nothing is added
to the site build (there isn't one).

## How the margins are filled

Scaling a photo **up** just crops in, so it always covers the canvas. Scaling
**down** leaves margins. Those are filled by stretching the source's own two
outermost pixel rows/columns outward. It is seamless here for two reasons: the
backdrop is flat (measured deviation 0–5 per channel), and the torso leaves the
bottom edge close to vertical, so extending the bottom row continues the body
straight down instead of leaving a hole.

If a future photo has a gradient backdrop or a subject that leaves the bottom
edge at an angle, this trick will show — re-shoot or re-cut the subject onto a
flat backdrop first.

## Gotchas

- **Always fit from the original photo, not from a fitted file.** Each pass
  resamples.
- The backdrop *colour* still varies between shoots (`#AEA794` on Annie's
  through `#D7D3CA` on Rachel's). This tool does not touch colour — it only
  fixes size and position.
- `--measure-only` prints the detected face width, centre, eye line and
  backdrop colour. Use it before and after to prove a change did what you meant.
