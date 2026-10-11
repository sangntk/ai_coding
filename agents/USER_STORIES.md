# English Learning Assistant — Complete User Stories for Review

**Version reviewed:** deployed demo v33 (2026-10-11)  
**Purpose:** source-of-truth backlog for the current demo and the later Vibe Flow implementation. This document is for the product owner to read, correct, and approve before further implementation.

## Product vision and non-negotiable decisions

Build a private, personal English-learning assistant that helps a learner grow from A1/A2 toward B2 by learning vocabulary and actively using it in speaking and writing. IELTS-style Speaking/Writing is a practice format, not the whole product. The AI should act like a personal tutor: adapt the focus to the learner's gaps, explain corrections, and preserve progress across sessions.

- AI should use the platform's managed AI capability for the demo; do not hard-wire an external provider unless the owner approves.
- Use a real database and account-based progress persistence, not browser-only state.
- Re-visiting the same topic should use a different new-word list until the eligible unseen bank is exhausted. Previously seen words may return in review activities.
- Do not integrate Cambridge Dictionary API in this demo phase. Vocabulary-source attribution and verification status must still be visible.
- Keep the app personal/private by default. Sharing with external reviewers requires a deliberate visibility decision in Hatchable settings.
- Every AI-generated or inferred vocabulary field remains draft/proposed until independently checked. A CEFR source estimate must not be described as officially verified.
- Do not mark a word as mastered merely because it appeared in a session.
- No invented vocabulary, source URLs, pronunciation, CEFR certainty, collocations, word families, or learner-error examples.
- Spaced-repetition scheduling is not a required deliverable for this demo unless added later by the product owner.

## How to read the evidence

Screenshots below are **real captures of deployed demo v33** at 1440px desktop width, using an anonymous/visitor preview. They show the currently visible UI, not redesigned mockups. Authenticated learning flow screenshots are not yet available because no test account/session was supplied. Where a screenshot shows a sign-in state, it is not proof that the signed-in history view works.

## Epic A — Account, privacy, and persistence

### US-AUTH-01 — Sign in to a personal learning space
**As a learner, I want to sign in with my email, so that my vocabulary, journal, and learning progress belong to me and persist across visits.**

Acceptance criteria:
- Email sign-in flow clearly explains the one-time code and provides loading, success, invalid-code, expired-code, resend, and retry states.
- After sign-in, the account identity is visible and sign-out is available.
- Reloading the app or returning in a new session restores the learner's saved progress from the database.
- A signed-out learner can browse non-personal topic previews but cannot read or mutate another learner's journal, sessions, attempts, or progress.
- Account/API failures show a recoverable message and do not silently reset local answers.
- The product owner can verify account deletion/data-retention policy before any public launch.

Current status: sign-in screen is visible in the demo; cross-session persistence and all error states require authenticated end-to-end verification.

Evidence — current sign-in screen:
![Current sign-in screen](../public/ux-evidence/v33-login.png)

### US-SEC-01 — Keep personal data private
**As a learner, I want my learning history and journal to be private, so that my personal reflections and progress are not exposed to other accounts.**

Acceptance criteria:
- All user-owned records are queried and mutated using the authenticated user ID on the server, never a user ID supplied by the browser.
- Cross-account access tests prove that one user cannot read, update, or delete another user's data.
- Journal text and AI practice responses are not exposed through public endpoints or logs.
- Topic catalog endpoints may be public only if they contain non-personal vocabulary data.
- The demo's Hatchable project visibility and the app's own sign-in are documented separately; the platform's sign-in wall is not mistaken for the app's own login.

Current status: API routes for learning history and journal are user-gated in source. Cross-account security testing is still required.

## Epic B — Explore topics

### US-TOPIC-01 — Browse every learning topic
**As a learner, I want to browse all available topics, so that I can choose a topic that is relevant to my life, study, or goals.**

Acceptance criteria:
- “Explore topics” displays every active topic from the database, not just a hard-coded subset.
- Each card shows topic name, a short description, CEFR range, and a clear “View details” action.
- “View all topics” and the main navigation both open the full topic catalog.
- Topic browsing does not start a session or change progress.
- Loading, empty, and error states are clear; retry is available after a load failure.
- Topic cards remain readable on mobile, keyboard accessible, and visually consistent.

Current status: the full catalog endpoint returned 15 topics in smoke testing. The overview intentionally shows a subset; the full catalog view displays all topics.

Evidence — current full topic catalog:
![Current Explore Topics page](../public/ux-evidence/v33-topics.png)

### US-TOPIC-02 — Preview a topic before starting
**As a learner, I want to view a topic's scope and vocabulary before starting, so that I can decide whether it fits my level and interests.**

Acceptance criteria:
- Selecting a topic opens a distinct in-app detail view and does not automatically start a session.
- Show topic name, description, CEFR range, total entries, single-word count, expression count, and B1/B2 counts where available.
- Preview each available word with term, part of speech, IPA when available, English definition, Vietnamese meaning, example, CEFR label, and draft/verification status.
- Provide clear “Start learning” and “Back to all topics” actions.
- Empty topics show a helpful empty state; never invent preview words.
- Errors show a retry action and do not leave the page blank.
- Topic details work on desktop and mobile.

Current status: the Travel detail endpoint returned HTTP 200 and 12 preview words in smoke testing. Authenticated/session start still needs a browser-level test.

Evidence — current Travel topic detail:
![Current topic detail page](../public/ux-evidence/v33-topic-detail-travel.png)

### US-TOPIC-03 — Understand source and level confidence
**As a learner, I want to know whether a word's source and level are verified, so that I do not mistake an estimate for a guarantee.**

Acceptance criteria:
- Show source name and a retrievable source URL when available.
- Label source-derived CEFR as an estimate until independently verified.
- Distinguish AI-generated draft definitions/examples and AI-proposed topic links from human-reviewed data.
- Do not display model confidence as a calibrated probability.
- A missing source or uncertain field is explicitly marked as unavailable/needs review rather than fabricated.

## Epic C — Start a focused, non-repeating learning session

### US-LEARN-01 — Start a session intentionally
**As a learner, I want to explicitly start a session from a topic, so that browsing a topic does not accidentally create progress records.**

Acceptance criteria:
- A session starts only after the learner presses “Start learning”.
- The flow is visible and predictable: pre-test → learning focus → word cards/flashcards → vocabulary test → Speaking/Writing → structured feedback → synthesis → post-test/re-test → saved progress.
- Show current step, progress through the session, and clear next/back actions where appropriate.
- Prevent duplicate session creation from double-clicks or network retries.
- If session creation fails, show a retry action and do not leave a spinner indefinitely.

### US-LEARN-02 — Get a fresh word set on topic revisit
**As a learner, I want each revisit to a topic to introduce a different set of new words, so that I steadily expand my vocabulary instead of seeing the same list repeatedly.**

Acceptance criteria:
- Track word exposure per learner and topic in the database.
- Do not select a previously unseen word as “new” if it has already been introduced to that learner in the same topic.
- Previously seen words may reappear in review, test, or re-test activities, labelled as review.
- When all eligible unseen words in a topic have been used, tell the learner and offer review or another topic; do not pretend the list is fresh.
- Selection is stable enough to avoid duplicate words inside a session and must not depend only on client-side memory.
- QA tests cover same topic twice, parallel session starts, reload/resume, and exhausted word bank.

Current status: non-repeating selection is a stated product requirement; needs regression tests over multiple visits and concurrent starts.

### US-LEARN-03 — Take a pre-test and see a learning focus
**As a learner, I want a short pre-test before learning, so that the session focuses on words I do not yet know.**

Acceptance criteria:
- The pre-test covers the session's candidate words and provides clear answer feedback.
- The result distinguishes correct recall from unfamiliar words.
- The system creates a learning-focus list from wrong/unknown answers, without excluding all other words from learning.
- The learner sees the score and a plain-language explanation of what to focus on.
- If saving fails, preserve all selected answers and allow retry without restarting the test.
- Do not claim diagnostic precision from a tiny sample; label it as a quick check.

### US-LEARN-04 — Learn a word with complete, sense-specific information
**As a learner, I want a clear word card for each word and sense, so that I understand both its meaning and how to use it naturally.**

Acceptance criteria for each eligible sense:
- **Basic information:** headword, part of speech, and a distinct record for each meaning/sense.
- **Pronunciation:** IPA stored separately for UK and US English when sourced; do not duplicate one accent as the other. Playable audio is optional and out of scope until a reliable audio source is chosen.
- **Explanation:** concise English definition that matches the sense and part of speech; natural Vietnamese equivalent for that same sense.
- **Example:** grammatical, natural sentence that demonstrates the selected sense, not just a sentence containing the word.
- **Usage:** natural collocations, established word-family forms, and common learner errors only when supported by evidence. Optional fields may be empty when uncertain.
- **Source and level:** source URL/license/provenance, CEFR value and explicit verification status.
- **Quality:** no malformed encoding, duplicate senses masquerading as distinct meanings, mismatched part of speech, fabricated citations, or made-up collocations/errors.
- Draft content is visibly labelled. A structural QA pass alone must not mark content verified.
- The learner can report a suspected error or mark a card for later review.

Current status: the vocabulary database is being enriched in batches. The extended usage-detail schema exists; the portable pipeline still needs to be upgraded to populate all fields before handoff.

### US-LEARN-05 — Use flashcards and vocabulary checks
**As a learner, I want to review words with flashcards and short tests, so that I actively recall meanings rather than passively read lists.**

Acceptance criteria:
- Cards support reveal/hide, next/previous, and a clear way to mark “know it / need practice” without confusing self-rating with objective mastery.
- Tests have unambiguous answer options, no duplicate correct options, and answer order is randomized without changing correctness.
- Show score and explanations after each test.
- Test questions and answer keys are generated from the exact sense being taught.
- Empty/short word banks are handled gracefully; do not pad with fabricated definitions or unrelated meanings.
- The learner can return to a card from a wrong answer.

### US-LEARN-06 — Practice Speaking and Writing with AI feedback
**As a learner, I want to answer Speaking and Writing prompts using new vocabulary and receive specific corrections, so that I can use words in real communication.**

Acceptance criteria:
- Each topic provides at least one relevant Speaking prompt and one Writing prompt. IELTS-style prompts are supported, but not required for every exercise.
- The learner can type a speaking transcript or answer and write a response; voice recording/transcription is optional and not a demo blocker unless explicitly added.
- AI feedback is structured into: (1) what worked, (2) grammar corrections, (3) vocabulary use, (4) naturalness/clarity, (5) a suggested improved version, and (6) one actionable next step.
- Corrections show the original phrase, corrected phrase, and a concise explanation in learner-friendly language.
- Correct the learner's grammar in both speaking transcripts and writing.
- Feedback must not falsely claim an IELTS band score unless a validated scoring rubric is implemented; use practice feedback rather than official assessment.
- Save the attempt, prompt, answer, feedback, and timestamp to the authenticated learner's history.
- If AI fails, preserve the original draft and allow retry. Never clear the answer or force the learner to retype it.

Current status: the feedback endpoint had four HTTP 503 errors in recent logs (2026-10-10). This is a known reliability item to investigate before calling the full flow complete.

### US-LEARN-07 — Complete post-test, re-test, and synthesis
**As a learner, I want to test myself again after practice, so that I can see what improved and what still needs work.**

Acceptance criteria:
- Post-test uses the same taught senses and a comparable difficulty to the pre-test, but does not simply repeat identical questions in the same order.
- Re-test can target missed/low-confidence words.
- Show pre-test vs post-test vs re-test results side by side and explain the change without overstating learning from a small sample.
- Synthesis summarizes learned words, common errors, useful collocations, and a small next step.
- The session cannot be marked completed until required stages and at least one saved practice attempt are present.
- Partial sessions remain resumable or clearly labelled incomplete; do not silently mark them complete.

### US-LEARN-08 — Preserve work when something fails
**As a learner, I want my answers and progress to survive an AI or network failure, so that I do not lose work.**

Acceptance criteria:
- Save draft answers locally during an active session and persist them server-side when possible.
- On timeout/5xx, show the error and a retry button; retain the answer, selected options, current step, and session ID.
- Retry operations are idempotent and do not create duplicate attempts/sessions.
- Clearly distinguish “saved”, “saving”, and “not saved”.
- A failure must never count as a correct answer or award mastery.

## Epic D — Progress and review

### US-PROGRESS-01 — View all learned and encountered vocabulary
**As a learner, I want a searchable list of words I have studied, so that I can revisit meanings and see which words I have actually learned.**

Acceptance criteria:
- “My progress” includes a dedicated vocabulary list independent of the session-history cards.
- List words that were introduced, practiced, answered correctly, or marked for review with separate statuses.
- Search by word and filter by topic, date, CEFR estimate, part of speech, and learning status.
- Each row/card can expand to show IPA, definition, Vietnamese meaning, example, source/verification status, times seen, correct recalls, and mastery indicator where available.
- Link each word to its topic/session history and vocabulary graph.
- Provide clear empty, loading, error, and retry states.
- A word that appeared in a session is not automatically labelled mastered.
- The list must load from the authenticated user's persisted data after a new login/device/session.

**Known user-reported issue:** the learned-vocabulary list is currently not reliably viewable. Treat this as high priority and do not close the story until tested with a signed-in account after completing at least one session.

Evidence — current My Progress view when signed out (this does **not** verify the signed-in list):
![Current My Progress signed-out state](../public/ux-evidence/v33-progress-signed-out.png)

### US-PROGRESS-02 — Trust the dashboard metrics
**As a learner, I want the dashboard to show accurate progress, so that I can understand what I have done and what to do next.**

Acceptance criteria:
- Define each metric explicitly: unique words seen, words with correct recall, completed sessions, saved practice attempts, average post-test score, and estimated level.
- Counts are computed from database records scoped to the current learner and deduplicated correctly.
- Do not count an incomplete/failed attempt as completed.
- A word seen once is not automatically a mastered word.
- Show “not enough data yet” instead of a misleading level or score.
- The dashboard refreshes after a session is completed and after history changes.
- The estimated level is labelled as a rough internal estimate, not an official CEFR result.

### US-PROGRESS-03 — Review session history by date
**As a learner, I want to see prior sessions grouped by date and topic, so that I can resume or review past learning.**

Acceptance criteria:
- Each session card shows date, topic, status, pre/post/re-test scores, practice attempts, and its word list.
- Distinguish completed, in-progress, and interrupted sessions.
- Session details can be reopened for review; resuming an unfinished session must not create a duplicate.
- Sort newest first, with pagination/load-more for long histories.
- If the user has no history, show a useful empty state with a start-learning action.

### US-PROGRESS-04 — Understand mastery and review needs
**As a learner, I want a transparent indication of recall and review needs, so that I know which words deserve attention.**

Acceptance criteria:
- Show times seen, times correct, last reviewed, and mastery score only when backed by persisted events.
- Explain how mastery is calculated; do not present it as a scientific measure without validation.
- Use separate states for unseen, learning, needs review, and mastered.
- A single exposure or one correct answer cannot automatically mean mastered.
- Spaced-repetition scheduling is out of scope for this demo unless approved separately.

## Epic E — Journal and personal recommendations

### US-JOURNAL-01 — Turn a daily journal into topic suggestions
**As a learner, I want to write about my day in Vietnamese or English and receive relevant topic ideas, so that learning connects to my real life.**

Acceptance criteria:
- Accept Vietnamese or English text with clear length limits and validation.
- Return up to three relevant topics with a short reason for each.
- Suggestions can be previewed on a topic detail page; selecting a suggestion does not automatically start learning.
- Save the journal and recommendations privately under the current user.
- Preserve journal text if recommendation generation fails; allow retry.
- Empty, too-short, and too-long inputs have clear validation messages.

### US-JOURNAL-02 — Review and delete journal history
**As a learner, I want to revisit and delete my journal entries, so that I control my personal archive.**

Acceptance criteria:
- Show entries by date/time and any saved topic recommendations.
- Deletion requires confirmation and removes the correct user's entry and associated recommendations.
- A failed deletion leaves the entry visible and offers retry.
- Refresh and reload show the correct persisted state.

Current UI evidence — journal form appears on the Overview page:
![Current Overview and journal section](../public/ux-evidence/v33-overview.png)

## Epic F — Vocabulary relationships

### US-GRAPH-01 — Explore a word's knowledge graph
**As a learner, I want to explore synonyms, antonyms, collocations, phrasal verbs, idioms, and word-family relationships, so that I can understand how vocabulary connects.**

Acceptance criteria:
- Open a graph from a word card or history item.
- Label every edge with its relationship type and a contextual note when available.
- Distinguish sourced relationships from AI-proposed/draft relationships.
- Selecting a connected node opens its details when data exists.
- Large graphs remain usable on mobile; provide a list alternative for keyboard and screen-reader users.
- Missing relationships are shown as unavailable, not invented.

## Epic G — Usability, navigation, and accessibility

### US-UX-01 — Navigate without losing context
**As a learner, I want navigation and page states to be predictable, so that I can reach topics, sessions, progress, and journal without getting stuck.**

Acceptance criteria:
- Main navigation consistently exposes Overview, Explore Topics, Daily Journal, and My Progress.
- Each detail view has a clear back action and preserves useful context.
- No page is blank or inaccessible due to stale hidden-state classes or missing event handlers.
- Loading, empty, error, and success states have consistent styling.
- Buttons are labelled with clear verbs; avoid ambiguous icon-only controls.
- Layout works at desktop and mobile widths; focus states, semantic headings, keyboard navigation, and contrast are checked.
- User-facing copy is consistent in one chosen language per screen. English UI is acceptable for the demo, but errors must remain understandable.

### US-UX-02 — Understand what is clickable and what happened
**As a learner, I want clear feedback after every action, so that I know whether a topic opened, a test saved, or an answer was submitted.**

Acceptance criteria:
- Buttons show disabled/loading states while work is in progress.
- Toasts or inline messages describe success/failure in plain language.
- No action silently fails.
- Retry actions are available for recoverable network/AI errors.
- Avoid double submission and accidental session completion.

## Epic H — Vocabulary quality and operations

### US-DATA-01 — Maintain a trustworthy vocabulary bank
**As a learner, I want vocabulary information to be accurate and traceable, so that I can trust what I study.**

Acceptance criteria:
- Each word/sense has stable IDs and a clear part of speech.
- Store multiple senses separately when the meanings differ.
- Preserve source name, source URL, source/license, imported version where available, CEFR source value, and verification status.
- Keep US and UK IPA separate and respect the licenses of each upstream pronunciation dataset.
- Enrichment runs in batches of 100; two independent batches can run concurrently.
- Validate each batch for missing core fields, malformed scripts/encoding, duplicate records, sense/POS mismatch, malformed examples, and missing source traceability.
- Invalid records remain untouched and are queued for retry/review.
- AI-generated content remains draft until source/human verification. Never mark the whole bank verified just because automated checks pass.

### US-OPS-01 — Verify the deployed end-to-end flow
**As the product owner, I want the deployed demo tested through real user actions, so that we can distinguish an API smoke test from a working product.**

Acceptance criteria:
- Test in a real browser at desktop and mobile widths.
- Test signed-out and signed-in states separately.
- Complete a full path: sign in → browse topics → topic detail → start session → pre-test → learn words → test → Speaking/Writing → AI feedback → post-test/re-test → summary → progress list → sign out/in → confirm persistence.
- Test revisiting the same topic, no-repeat selection, duplicate clicks, page refresh, empty bank, AI timeout, and network failure.
- Verify every navigation destination renders and can be returned from.
- Capture screenshots for each meaningful screen/state and attach them to the relevant story.
- Record expected vs actual, browser/viewport, evidence, severity, and regression result.
- Do not mark the demo “done” from endpoint status codes alone.

## Current UI evidence and issues observed

| ID | Evidence | What it proves | What it does not prove / next action |
|---|---|---|---|
| E-01 | ![Overview](../public/ux-evidence/v33-overview.png) | Overview, journal entry form, metrics, topic preview, session entry point render in visitor preview. | Does not prove signed-in dashboard metrics or session completion. |
| E-02 | ![Topics](../public/ux-evidence/v33-topics.png) | Full topic catalog view renders 15 topic cards in visitor preview. | Does not prove all card actions or mobile behavior. |
| E-03 | ![Topic detail](../public/ux-evidence/v33-topic-detail-travel.png) | Travel topic detail and vocabulary preview render. | Does not prove that Start Learning completes the authenticated flow. |
| E-04 | ![My Progress signed out](../public/ux-evidence/v33-progress-signed-out.png) | Progress view shows a sign-in gate when anonymous. | Signed-in learned-vocabulary list is a known user-reported issue and must be tested. |
| E-05 | ![Sign in](../public/ux-evidence/v33-login.png) | Email one-time-code sign-in screen renders. | Does not prove email delivery, OTP acceptance, or session persistence. |

Known verification signals:
- Topic catalog API and Travel detail API returned HTTP 200 in smoke tests.
- The learning-feedback endpoint logged four HTTP 503 responses on 2026-10-10; investigate provider/configuration failure and verify draft preservation.
- The user reports that some pages are not viewable and the learned-word list cannot currently be viewed reliably. This is not closed by the anonymous screenshot or API smoke tests.
- The project is private/personal. Non-collaborators encounter Hatchable's platform sign-in wall before the app. If external demo reviewers must access it, the owner must intentionally change project visibility in Hatchable settings.

## Priority order for the next iteration

1. **P0 — Signed-in learning history / learned vocabulary list:** reproduce the user-reported issue with a test account; ensure list, empty/error states, filters, and persistence work.
2. **P0 — Full end-to-end flow and data persistence:** sign in, complete a session, reload, and confirm that the same words/scores/feedback appear.
3. **P1 — AI feedback reliability:** diagnose recent 503s; preserve answer drafts and make retry idempotent.
4. **P1 — UX/navigation audit:** test every nav item, back action, loading/empty/error state, mobile viewport, and keyboard flow.
5. **P1 — Non-repeating word selection:** test across multiple sessions and concurrent starts.
6. **P1 — Vocabulary quality pipeline handoff:** update the portable Vibe Flow script to write every required field and preserve verification states.
7. **P2 — Visual polish:** consistent spacing, hierarchy, readable word cards, progress list search/filter, and clear distinction between new words and review.
8. **P2 — Later scope:** audio pronunciation, richer graph interactions, validated assessment rubrics, and spaced repetition only after product-owner approval.

## Product-owner verification checklist

- [ ] The vision and exclusions match what I want to build.
- [ ] The session flow and non-repeat rule are correct.
- [ ] The fields required on every word/sense are complete.
- [ ] Speaking/Writing feedback criteria are correct.
- [ ] The learned-vocabulary list and mastery definitions are correct.
- [ ] The priority order reflects my preferred MVP.
- [ ] I have reviewed the current screenshots and marked which UI changes I want.