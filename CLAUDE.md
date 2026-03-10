# Team Human - Project Guide

## Overview
Team Human is a community homepage for an AI-era human-centered tech community based in Seoul. The site showcases the team's beliefs, members, and events (Cursor Meetups & Hackathons).

## Tech Stack
- **Pure HTML/CSS/JS** — no build tools, no frameworks
- **Hosting:** Vercel (auto-deploy on push to `main`)
- **Repo:** github.com/dave-jin/team-human
- **Domain:** team-human.vercel.app

## Project Structure
```
index.html          # Homepage (hero, beliefs, team, footer)
events.html         # Events page (event cards)
styles.css          # All styles (responsive, Korean font support)
i18n.js             # i18n engine (KO/EN switcher, localStorage)
i18n/en.json        # English translations
i18n/ko.json        # Korean translations
images/
  hackathon-hero.png
  PFP/              # Team member profile photos (Danny, Dave, Eric, Kelly, Rachel, Sirial, Annie, Chedda)
.vercel/            # Vercel project config
```

## Key Conventions

### i18n
- All user-facing text uses `data-i18n="key"` attributes
- Translations live in `i18n/en.json` and `i18n/ko.json`
- Default language: English (`en`)
- Korean mode uses `Noto Serif KR` font family
- English mode uses `Source Serif 4` and `Inter`

### Team Members
When adding/editing team members, update **3 files**:
1. `index.html` — card markup (name, photo, description, LinkedIn link)
2. `i18n/en.json` — English description (`team.<name>.desc`)
3. `i18n/ko.json` — Korean description (`team.<name>.desc`)

Team cards are **randomly shuffled** on each page load via `shuffleTeamCards()` in `i18n.js`.

### Current Team (8 members)
| Name | i18n Key | LinkedIn |
|------|----------|----------|
| Danny Kim | team.danny | /in/jydkim |
| Dave Jin | team.dave | /in/davejin |
| Eric Kim | team.eric | /in/jaeyeonerickim |
| Kelly Woo | team.kelly | /in/jiheewoo |
| Rachel Lee | team.rachel | /in/rachelselee |
| Sirial Jeon | team.sirial | /in/sijinjeon |
| Annie Seo | team.annie | /in/ga-on-seo-8b5989165 |
| Chedda Choi | team.chedda | /in/cheddachoi |

### Design
- Background: `#EDE8E0` (warm cream)
- Text: `#2B2220` (dark brown)
- Accent: `#C45C26` (orange, event dates)
- Cards: white background with subtle hover shadows
- Responsive breakpoints: 1024px, 768px

### Deployment
Push to `main` branch triggers Vercel auto-deploy. No build step needed — static files served directly.

### Collaborators
- dave-jin (owner)
- erickimme (write access)
