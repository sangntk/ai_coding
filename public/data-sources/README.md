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
   - `--classify`: propose 0–2 topic assignments based on the definition and part of speech.
4. Store AI classifications in `topic_classification_reviews` with `review_status='ai_proposed'`; this is not a human approval.
5. Rebuild `topic_vocabulary` from the review table, rather than trusting the old raw topic associations.
6. Sample-audit translations, examples, topic assignments and CEFR estimates before promoting records to a trusted/approved state.
7. Keep learning progress in user-specific tables; do not overwrite learner history during vocabulary refreshes.

## Current snapshot (2026-10-11)
- 248,184 upstream POS records imported; 172,782 distinct normalized terms in the source records.
- 34,335 A1–B2 candidate entries were originally added as draft without definitions or topic links.
- 134 of those draft entries now have an AI-generated definition, Vietnamese meaning and example; these remain drafts.
- 3,117 topic classification review records exist; 2,828 have one or more proposed topic assignments and 289 intentionally have no topical assignment.
- `topic_vocabulary` has been rebuilt from the classification review table, replacing the earlier noisy links. Existing pre-cleanup mappings are retained in `topic_vocabulary_backup_20261011`.
- AI-generated data is provisional. The current import still has 34,201 entries without a definition, Vietnamese meaning or example and needs ongoing enrichment.

## Reuse on Vibe Flow
Apply `migrations/20261011_topic_mapping_cleanup.sql`, configure secrets server-side, import source records, and run the quality pipeline with a small `BATCH_SIZE`. Keep the script outside client bundles. The current app uses Hatchable's managed AI service; the portable script uses the OpenAI API directly, so Vibe Flow can run it in a scheduled worker or secure server-side job.