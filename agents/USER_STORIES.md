# English Learning Assistant — User Stories (working draft)

**Purpose:** Build a private, personalized vocabulary-learning assistant that helps learners expand vocabulary from A1 toward B2 and actively use it in speaking and writing. IELTS-style tasks are one practice format, not the whole product.

## Epic: Explore and choose a topic

### US-TOPIC-01 — Browse all topics
**As a learner, I want to browse all available topics, so that I can choose what I want to learn.**

Acceptance criteria:
- The Explore Topics page lists every topic returned by the database, not only the first six.
- Each topic card shows its name, short description, CEFR range, and an action to view details.
- The page is reachable from the main navigation and the Overview page's “View all topics” action.
- Browsing topics does not create a learning session or change progress.

### US-TOPIC-02 — View topic details
**As a learner, I want to open a dedicated detail page for a topic, so that I can understand its scope and learning content before starting a session.**

Acceptance criteria:
- Selecting a topic opens a dedicated in-app page/view for that topic; it must not automatically start a session.
- The page displays topic name, description, CEFR range, and counts for single-word entries and expressions (phrases, collocations, idioms).
- The page shows a preview of vocabulary with the term, part of speech, IPA when available, English definition, Vietnamese meaning when available, example sentence, and CEFR label.
- The page provides a clear “Start learning” action. Only this action begins the existing pre-test → learn → practice flow.
- A “Back to all topics” action returns to the Explore Topics list.
- Missing or empty vocabulary is handled gracefully with an empty state; no fabricated entries are shown.
- The page works on desktop and mobile and preserves the existing database records.

### US-TOPIC-03 — See topic coverage and learning focus
**As a learner, I want to see the topic's vocabulary coverage before learning, so that I can choose a suitable topic and level.**

Acceptance criteria:
- Show total vocabulary entries, split between single words and multi-word expressions.
- Show the current topic CEFR range and available B1/B2 entry counts where data exists.
- Clearly label unverified/draft vocabulary metadata; do not imply that draft CEFR levels or relationships are officially verified.
- Counts are derived from the database and update when topic-vocabulary links change.

## Epic: Learn from real life

### US-JOURNAL-01 — Get topic suggestions from a daily journal
**As a learner, I want to describe what I did, ate, saw, or felt today and receive relevant topic suggestions, so that vocabulary learning connects to my real life.**

Acceptance criteria:
- The learner can write a journal entry in Vietnamese or English.
- The app returns up to three relevant topics with a short explanation for each recommendation.
- The learner can open a recommended topic detail page before choosing to start learning.
- Journal entries are private to the learner and can be deleted.

## Epic: Learn and use vocabulary

### US-LEARN-01 — Start a learning session
**As a learner, I want to start a session from a topic, so that I can learn a fresh set of vocabulary.**

Acceptance criteria:
- A session begins only after the learner explicitly selects “Start learning”.
- The intended flow follows: topic/quote → pre-test → result/learning focus → flashcards or word cards → test → speaking/writing practice → feedback/correction → synthesis → re-test → progress.
- New-word lists should not repeat for the same learner and topic until the available unseen bank is exhausted; previously learned words may reappear in review activities.
- The system distinguishes new exposure from mastery and review.

### US-LEARN-02 — Explore word relationships
**As a learner, I want to explore synonyms, antonyms, collocations, phrasal verbs, and idioms in a graph, so that I can understand how vocabulary is connected.**

Acceptance criteria:
- A word detail/learning card can open its vocabulary graph.
- Graph edges have a relationship type and contextual note where available.
- Draft/unverified relationships are labelled as such.
- Selecting a connected term opens that term's graph when data exists.

## Epic: Track learning

### US-PROGRESS-01 — Review learning progress
**As a learner, I want to see my learned vocabulary and session history, so that I can understand my progress and what to review next.**

Acceptance criteria:
- Progress is tied to the authenticated learner.
- The app distinguishes learned, newly seen, and review-needed vocabulary when the underlying data supports those states.
- The app does not claim word mastery solely because a word appeared in a session.

## Non-functional requirements relevant to topic pages
- Topic catalog and vocabulary previews are read from the database, not hard-coded into the frontend.
- Topic detail browsing is read-only and must not create a learning session.
- All dynamic text is escaped before rendering.
- Pages are responsive and accessible by keyboard; controls have clear labels.
- The vocabulary source and verification status are retained for future audit.
- Keep AI feedback provider configuration out of scope until explicitly requested.

## Implementation note
The current demo uses in-app views inside one HTML shell rather than separate HTML files. “Dedicated page” means a distinct navigable view with its own content and back/navigation behaviour. It can later be migrated to Vibeflow as a route/page without changing the user-facing acceptance criteria.