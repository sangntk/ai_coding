# Vocabulary data sources and quality workflow

## Imported source data
- Words-CEFR-Dataset: MIT repository license. Preserve upstream attribution; its CEFR levels are derived estimates, not official guarantees.
- ipa-dict English US/UK: check the license for each variant independently. The UK data may be GPL-3.0; review obligations before redistributing a combined product.
- Open English WordNet 2025 was evaluated but is not imported into the current database.

## Quality workflow
1. Import upstream word/POS/IPA records into `vocabulary_source_records`; preserve source IDs, raw metadata, license, version and SHA-256 checksums.
2. Promote candidate headwords into `vocabulary_entries` as `draft`, without overwriting existing records.
3. Run the reusable `vocabulary-quality-pipeline.txt` in small batches:
   - `--enrich`: generate an English definition, Vietnamese meaning and example sentence.
   - `--classify`: propose at most one topic based on the definition and part of speech; generic or ambiguous words may remain unassigned.
4. Store AI classifications in `topic_classification_reviews` with `review_status='ai_proposed'`; this is not a human approval.
5. Rebuild `topic_vocabulary` from the review table, rather than trusting the old raw topic associations.
6. Sample-audit translations, examples, topic assignments and CEFR estimates before promoting records to a trusted/approved state.
7. Keep learning progress in user-specific tables; do not overwrite learner history during vocabulary refreshes.

## Current snapshot (2026-10-11)
- 248,184 upstream POS records imported; 172,782 distinct normalized terms in the source records.
- 34,335 A1–B2 candidate entries were originally added as draft without definitions or topic links.
- The initial enrichment generated content for 164 entries; 9 malformed or low-value candidates were rejected, leaving 155 retained drafts. Four subsequent 100-word batches ran as two concurrent pairs: 397 entries passed structural QA, while 3 malformed responses were left untouched for retry. Total retained entries with complete core fields is now 552; AI content remains draft and is not dictionary-verified.
- The 397 newly enriched records have a structured `vocabulary_usage_details` row for collocations, word family, common errors, US/UK IPA and source/license traceability. Their CEFR status is `source_estimate`; none are marked verified.
- 3,117 review records exist: 3,108 active entries received a strict audit, with 2,356 assigned one topic and 752 left unassigned; 9 low-quality entries are excluded.
- `topic_vocabulary` now has 2,356 links (one topic per linked entry). Pre-cleanup links are retained in `topic_vocabulary_backup_20261011`; pre-audit review records are retained in `topic_classification_reviews_backup_v30`.
- AI-generated data is provisional. A focused query of eligible A1–B2 noun/verb/adjective/adverb entries with alphabetic headwords reports 33,392 records still missing at least one core field after these batches; broader counts differ because they include rejected records and other POS/headword forms. The 552 retained enriched entries remain drafts.

## Reuse on Vibe Flow
Apply `migrations/20261011_topic_mapping_cleanup.sql` and `migrations/20261011_vocabulary_usage_details.sql`, configure secrets server-side, and import source records. The Hatchable-managed worker used for this audit processed batches of 100, with two batches running concurrently. The portable Node script in this folder is still an older core-only implementation capped at 50; update it to support offset-based parallel batches and write `vocabulary_usage_details` before reusing it as the full-checklist pipeline on Vibe Flow. Keep all secrets server-side and validate each batch before continuing. The current app uses Hatchable's managed AI service; the portable script uses the OpenAI API directly, so Vibe Flow can run it in a scheduled worker or secure server-side job.