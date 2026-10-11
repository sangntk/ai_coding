# Data sources and attribution

Large source CSVs have been ingested into PostgreSQL and are not needed as runtime dependencies.

- Words-CEFR-Dataset: https://github.com/Maximax67/Words-CEFR-Dataset — MIT repository license; retain upstream acknowledgements in its README. CEFR scores are computed estimates.
- IPA dictionary: https://github.com/open-dict-data/ipa-dict — check each language file's credits. The US and UK variants are tracked separately because the repository notes different upstream licenses (US MIT-derived, UK GPL-3.0/ipacards-derived).
- Open English WordNet: https://en-word.net/downloads — CC BY 4.0. Current graph data has not been upgraded to the 2025 edition. The archive is a future candidate, not part of the current import.

See ../data-pipeline.md for the schema, pipeline stages, validation and Vibe Flow handoff. No API keys or database credentials belong in this directory.