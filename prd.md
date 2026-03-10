# Team Human — Product Requirements Document

## Product Vision
Team Human is a community of product makers in Seoul who believe the best technology starts with empathy, creativity, and real human connection. The website serves as the community's public face — introducing who we are, what we believe, and what events we host.

## Target Audience
- Product makers (designers, developers, PMs) in Seoul
- Attendees and potential attendees of Cursor Meetups & Hackathons
- Anyone interested in human-centered tech communities

## Pages

### 1. Homepage (`index.html`)
- **Hero Section:** Community tagline + hackathon group photo
- **Beliefs Section:** 4 core values (Empathy First, Creative Courage, Community Over Competition, Craft Matters)
- **Team Section:** 8 member cards with profile photos, personalized quotes, and LinkedIn links. Cards are randomly shuffled on each page load.
- **Footer:** Logo + tagline

### 2. Events Page (`events.html`)
- **Event Cards:** Each event has an image, title, date, and location
- **Current Events:**
  - Cursor Hackathon Seoul (Feb 07, 2026)
  - Cursor Network Build Day (Mar 04, 2026)
  - Cursor Meetup: Design, Build, Ship (Oct 25, 2025)
  - Cursor Meetup Seoul (Jun 14, 2025)

## Team Members & Profiles

| Name | Role/Background | Quote (EN) |
|------|----------------|------------|
| Danny Kim | Pharmacist, Operator, Investor at WELT corp. Forbes 30 Under 30. Digital health. | AI can scale solutions, but only humans can ask the right questions. That's why we gather. |
| Dave Jin | Moment Studio. AI/no-code strategist. Vibe Coding advocate. Author. | In an era where anyone can build, the real edge is building together — with intention and heart. |
| Eric Kim | One Degree Labs. Hackathon winner. SaaS Study Group co-founder. | The most impactful projects start not with code, but with people who show up for each other. |
| Kelly Woo | Korea Investment Accelerator. Startup strategy. Award-winning marketer. | When makers connect honestly, magic happens. I'm here to make sure those connections keep growing. |
| Rachel Lee | Product Designer at SAIGE. Figma plugin creator. Cursor community organizer. | We don't just talk about building — we design, ship, and learn together in the open. |
| Sirial Jeon | CEO of Sireal Consulting. 1 of 2 Notion Certified Consultants in Korea. Bestselling author. | AI changes how we work, but community changes why we work. That's worth getting right. |
| Annie Seo | Tech Recruiter. Vibe coder. Coaching for Tech Recruiting, Networking, DevRel. | Behind every great product is a team that found each other. I help make those introductions happen. |
| Chedda Choi | DevRel. Empowers developers to shine. Bridges internal teams with external audiences. | Developers deserve a stage, not just a desk. I'm here to help them share, connect, and grow. |

## Internationalization (i18n)
- **Supported Languages:** Korean (ko), English (en)
- **Default:** English
- **Switching:** Language switcher in header nav (KO / EN toggle)
- **Storage:** User preference saved in `localStorage`
- **Korean Typography:** Noto Serif KR for body text in Korean mode

## Design System
- **Palette:** Warm cream (#EDE8E0), dark brown (#2B2220), muted gray (#5C5C5C), accent orange (#C45C26)
- **Typography:** Source Serif 4 (hero, titles), Inter (body, UI), Noto Serif KR (Korean mode)
- **Layout:** Responsive grid — 3 columns on desktop, 1 column on mobile
- **Cards:** Rounded corners (8-12px), subtle hover elevation

## Technical Architecture
- **No build tools** — vanilla HTML, CSS, JS served as static files
- **Hosting:** Vercel with GitHub integration (auto-deploy on push to `main`)
- **i18n:** Custom lightweight engine (`i18n.js`) — fetches JSON translation files, applies via `data-i18n` attributes
- **Team Shuffle:** Fisher-Yates shuffle on `.team-grid` children at DOMContentLoaded

## Future Considerations
- Add event registration links (currently `href="#"`)
- Individual member detail pages
- Blog/content section for community updates
- Event photo galleries
- Member contribution/role tags
