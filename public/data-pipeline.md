# English Learning Assistant — reusable vocabulary data pipeline

This is the handoff specification for reusing the pipeline in Vibe Flow or another PostgreSQL-backed environment.

## Current import snapshot

- Imported **248,184 POS-specific records** from Words-CEFR-Dataset into vocabulary_source_records.
- The records cover **172,782 distinct normalized terms**.
- Merged IPA lookups into those records: US source has 125,927 entries; UK source has 65,119 entries.
- Promoted **34,335 new A1–B2 single-word candidates** into vocabulary_entries as draft. Existing vocabulary records were not overwritten during promotion.
- Generated AI definitions, Vietnamese meanings and examples for 164 entries over two batches; a quality audit rejected 9 malformed or low-value candidates, leaving **155 enriched draft entries**; none are dictionary-verified.
- Re-audited **3,108 active topic entries** with a stricter semantic rule: at most one topic per entry, or no topic when the meaning is generic/ambiguous. **2,356** now have one active topic; **752** are intentionally unassigned; 9 additional low-quality entries remain excluded. The assignments are still AI-proposed, not human-approved.

## Sources and licenses

1. **Words-CEFR-Dataset** — https://github.com/Maximax67/Words-CEFR-Dataset  
   Repository declares MIT. Preserve repository attribution and upstream acknowledgements in its README (including CEFR-J and Google Books Ngram). The CEFR values are computed estimates, not an official CEFR Vocabulary Profile.
2. **ipa-dict** — https://github.com/open-dict-data/ipa-dict  
   US and UK IPA lists are tracked separately. The repository says third-party data retains its own license; its credits identify the US list as modified cmudict-ipa-derived (MIT) and the UK list as ipacards-derived (GPL-3.0). Do not collapse these into a single license label.
3. **Open English WordNet 2025** — https://en-word.net/downloads  
   CC BY 4.0. Listed as a future graph-refresh source; the archive was fetched but not parsed into the database in this import.

Source license files and a reusable importer source (import-vocabulary.txt; rename to .mjs before running) are retained under /data-sources/. Large raw CSV/ZIP files are not shipped in the app; the importer fetches canonical source URLs.

## Processing pipeline

1. **Fetch** raw source data from canonical URLs. Record fetch date, source URL, version/commit where available, and SHA-256.
2. **Parse** source IDs, words, POS tags, frequency, and raw numeric level. Never discard source IDs or raw level scores.
3. **Normalize** only for matching: Unicode normalize, trim, lowercase. Preserve the original display term.
4. **Join IPA** on normalized spelling, keeping US and UK pronunciations in separate fields and recording provenance separately.
5. **Stage the full source** in vocabulary_source_records using stable key (source_key, source_record_id). Use upsert so reruns are idempotent.
6. **Promote candidates** into vocabulary_entries only as draft. The initial promotion selects alphabetic single-word entries with A1–B2 scores, excludes proper-noun POS tags, chooses one representative POS per spelling, and never overwrites an existing normalized term.
7. **Enrich** missing definitions, Vietnamese meanings and examples in small batches. AI-generated senses are stored with source_status='draft'.
8. **Classify topics** separately from enrichment. Store each decision in topic_classification_reviews with topics, model confidence, method, rationale and review_status='ai_proposed'. A confidence score is a model estimate, not a calibrated probability.
9. **Rebuild topic links** from topic_classification_reviews, not from the legacy associations. The old mapping is preserved in topic_vocabulary_backup_20261011.
10. **Validate** duplicates, IPA coverage, valid CEFR values, POS quality, topic relevance, license metadata and sample entries in every CEFR band. Promote to trusted/approved only after human review.
11. **Monitor** import counts, source hashes, rejected rows, duplicate counts and errors on every run.

## CEFR score mapping used for the initial candidate view

The raw numeric score is retained in source_level_score. The initial derived label uses score boundaries 1.5, 2.5, 3.5, 4.5 and 5.5 for A1–C2. Treat this as a derived label and audit the distribution and examples before using it for learner-facing assessment. The dataset's labels are algorithmic estimates.

## Database contract

- vocabulary_import_sources: source name, URL, license, attribution, snapshot label, import timestamp, record count, hash and notes.
- vocabulary_source_records: raw/source-level POS records, source row ID, original term, normalized term, raw numeric level, derived CEFR label, frequency, US/UK IPA and separate IPA provenance.
- vocabulary_entries: application vocabulary. Imported candidates are draft and have no generated definition/translation/example until enriched.
- topic_vocabulary: active links currently have at most one topic per entry; links are rebuilt only for entries represented in topic_classification_reviews. Unreviewed curated/session-created links are preserved by the reusable pipeline.
- topic_classification_reviews: one row per classified entry, with topics array, confidence, method, review status and rationale. Empty topics means no sufficiently strong topical fit was assigned; active assignments remain ai_proposed.
- topic_classification_audit_v30: staged/applied strict-audit decisions, including the rationale for each assignment. topic_classification_reviews_backup_v30 preserves the review table as it was before the strict audit.

Schema migrations: migrations/20261011_vocabulary_data_pipeline.sql, migrations/20261011_topic_mapping_cleanup.sql, and migrations/20261011_topic_strict_audit_v30.sql. Reusable sources: data-sources/import-vocabulary.txt (rename to import-vocabulary.mjs) and data-sources/vocabulary-quality-pipeline.txt (rename to vocabulary-quality-pipeline.mjs).

## Reuse in Vibe Flow

1. Apply the schema migration to the target PostgreSQL database.
2. Run data-sources/import-vocabulary.mjs in a server-side job, not browser code.
3. Set DATABASE_URL only in server-side secrets and install the pg package.
4. Run once in staging, compare source row counts and hashes, review sampled words and licenses, then run against production.
5. Reuse the same source keys and upsert keys to make re-imports safe. Never expose database credentials in client code.
6. Run topic classification as a separate job; never infer a topic only from alphabetical position or frequency.

## Known limitations / next steps

- The original 34,335 draft candidates still require ongoing enrichment: 34,180 currently have no definition, Vietnamese meaning or example, including 9 candidates explicitly rejected from learning use. The current batch work retained 155 enriched entries, all still draft.
- The strict audit has been applied to all 3,108 non-excluded review entries: 2,356 have one active topic and 752 are unassigned. Nine malformed/low-value entries are excluded. The pre-cleanup topic links remain in topic_vocabulary_backup_20261011; the pre-audit review records remain in topic_classification_reviews_backup_v30.
- Topic assignments and generated translations/examples still require human sampling before they should be treated as verified.
- Open English WordNet 2025 is recorded as a candidate source but is not ingested; the current graph should not be described as 2025-updated.
- Review the GPL-3.0 implications of the UK IPA source before distributing a combined derivative dataset.