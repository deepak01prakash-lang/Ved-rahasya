# Scripture corpus and translation policy

## Product requirement

The Granthalaya is intended to become a complete, structured digital reading library. For every work, the app will present three parallel layers:

1. Original Sanskrit (Devanagari), preserving the source edition's wording, accents and numbering where supplied.
2. A newly prepared Hindi meaning translated from that Sanskrit source.
3. A newly prepared English translation translated from that same Sanskrit source.

The Sanskrit text is the source of truth. Hindi and English must never be copied from a modern publisher's translation unless its licence explicitly permits the intended distribution and commercial use.

## Rights and source checks

- The age of an ancient work does not automatically make every modern digital edition free to republish.
- Record the exact edition, transcription source, URL, licence, attribution and any share-alike/non-commercial conditions for each imported corpus.
- Do not use a non-commercial-only corpus in a monetized app unless written permission is obtained.
- CC BY-SA material requires attribution and compatible share-alike treatment of adaptations; retain the licence notice with the work.
- AI-assisted translations must be generated from the verified Sanskrit, not from an existing Hindi/English translation. Each translation needs human review for grammar, context, philosophical terminology and verse alignment.
- Do not promise that AI output is automatically copyright-free. Keep a generation/review record and obtain legal review before commercial publication.
- Never silently repair, modernize or merge variant readings. Store recension, shakha, edition and variant notes separately.

## Current corpus manifest

See `assets/data/scripture_catalog.json`. It records planned works and current ingestion status. A catalogue entry is not evidence that the full text has been imported. The Bhagavad Gita dataset already in `assets/data/gita_verses.json` must still be audited for all 18 chapters, 700 verses, numbering, source edition and text integrity before being marked complete.

## Reader requirements

- Work → recension/edition → book/kanda/skandha/mandala → chapter/sukta → verse/mantra navigation.
- Sanskrit / हिंदी / English tabs, with verse-aligned display.
- Search by title, Sanskrit words, chapter and verse reference.
- Bookmark and resume reading position.
- Source and licence visible inside each work.
- Clearly label unavailable translations and incomplete source sections; never fabricate missing verses.
- Support offline reading after the licensed corpus is bundled.

## Ingestion workflow

1. Select a public-domain or commercially compatible digital edition.
2. Verify its licence and attribution requirements from the source's own terms.
3. Import the complete Sanskrit corpus and preserve source identifiers and structure.
4. Run structural checks (expected chapter/verse counts, duplicate IDs, gaps, malformed text).
5. Generate Hindi and English translations from Sanskrit in small aligned batches.
6. Have a Sanskrit/Hindi/English reviewer check the translations and record approval.
7. Run regression tests and publish a corpus version with source and licence manifest.

## Initial source research (not blanket permission)

- Sanskrit Wikisource pages can carry CC BY-SA 4.0 page contributions; verify the specific page and its history before reuse.
- The gita/gita Bhagavad Gita dataset is identified as Unlicense in its repository metadata; preserve the source attribution and audit the exact release.
- GRETIL files often have source-edition-specific terms; some are non-commercial. Review each file individually.
- Muktabodha searchable e-texts are CC BY-NC 4.0 and therefore must not be included in a monetized app without separate written permission. Its Gokarna manuscript collection has stricter restrictions.

These notes are a source-selection checklist, not legal advice or a blanket clearance for any text.
