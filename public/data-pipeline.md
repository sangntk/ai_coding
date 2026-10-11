# English Learning Assistant — reusable vocabulary data pipeline

This is the handoff specification for reusing the pipeline in Vibe Flow or another PostgreSQL-backed environment.

## Current import snapshot

- Imported **248,184 POS-specific records** from Words-CEFR-Dataset into vocabulary_source_records.
- The records cover **172,782 distinct normalized terms**.
- Merged IPA lookups into those records: US source has 125,927 entries; UK source has 65,119 entries.
- Promoted **34,335 new A1–B2 single-word candidates** into vocabulary_entries as draft. They are not automatically attached to topics or treated as verified.
- Existing vocabulary records were not overwritten during promotion. Existing topic associations were not rebuilt.
- Definitions, Vietnamese translations, examples and topic labels are not supplied by the CEFR dataset; these fields must be sourced or generated and checked separately.

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
7. **Enrich** missing definition, Vietnamese meaning, example, and topic tags from permitted sources or AI-generated drafts. Keep provenance and verification status. Never claim AI-generated content is dictionary-verified.
8. **Validate** duplicates, IPA coverage, valid CEFR values, POS quality, topic relevance, license metadata, and sample entries in every CEFR band.
9. **Publish** only approved items to learning sessions. Draft candidates must not become visible merely because they were imported.
10. **Monitor** import counts, source hashes, rejected rows, duplicate counts and errors on every run.

## CEFR score mapping used for the initial candidate view

The raw numeric score is retained in source_level_score. The initial derived label uses score boundaries 1.5, 2.5, 3.5, 4.5 and 5.5 for A1–C2. Treat this as a derived label and audit the distribution and examples before using it for learner-facing assessment. The dataset's labels are algorithmic estimates.

## Database contract

- vocabulary_import_sources: source name, URL, license, attribution, snapshot label, import timestamp, record count, hash and notes.
- vocabulary_source_records: raw/source-level POS records, source row ID, original term, normalized term, raw numeric level, derived CEFR label, frequency, US/UK IPA and separate IPA provenance.
- vocabulary_entries: application vocabulary. Imported candidates are draft and have no generated definition/translation/example until enriched.
- topic_vocabulary: curated topic links. Do not bulk-replace existing links until new classifications have full coverage and pass validation.

Schema migration: migrations/20261011_vocabulary_data_pipeline.sql. Reusable importer source: data-sources/import-vocabulary.txt (rename to import-vocabulary.mjs before running).

## Reuse in Vibe Flow

1. Apply the schema migration to the target PostgreSQL database.
2. Run data-sources/import-vocabulary.mjs in a server-side job, not browser code.
3. Set DATABASE_URL only in server-side secrets and install the pg package.
4. Run once in staging, compare source row counts and hashes, review sampled words and licenses, then run against production.
5. Reuse the same source keys and upsert keys to make re-imports safe. Never expose database credentials in client code.
6. Run topic classification as a separate job; never infer a topic only from alphabetical position or frequency.

## Known limitations / next steps

- Full source import is complete, but definitions, Vietnamese meanings, examples and topic mapping are not yet populated for the 34,335 promoted candidates.
- Existing topic mappings still need a separate repair. The source import intentionally did not overwrite them.
- Open English WordNet 2025 is recorded as a candidate source but is not ingested; the current graph should not be described as 2025-updated.
- Review the GPL-3.0 implications of the UK IPA source before distributing a combined derivative dataset.