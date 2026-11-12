# Scripture corpus audit

Audit date: 2026-11-12

## Current in-app text data

### Bhagavad Gita

The existing `assets/data/gita_verses.json` was parsed and structurally checked.

- 701 Sanskrit records are present.
- All 18 chapter numbers are represented.
- Every record has a non-empty Sanskrit text field.
- No duplicate chapter/verse keys were found.
- Chapter 13 includes Arjuna's question as a separately numbered 13.1 record. This numbering convention explains why this dataset contains 701 rows while some editions or counts present 700 verses by treating that question as unnumbered or differently numbered.
- Transliteration and lexical word-meaning fields exist in the dataset.
- Complete Hindi translations for all verses are not present.
- Complete English translations for all verses are not present.
- Only a small subset of Hindi word glosses is manually reviewed in the current reader.

This is a structural data audit, not a scholarly collation against every recension or printed edition. The Sanskrit corpus must continue to display its source and numbering caveat.

## Other listed works

The catalog currently lists the four Vedas, ten major Upanishads, Bhagavata Purana, Valmiki Ramayana and Mahabharata, in addition to the Gita. For those works, a catalog entry is not the same as an imported full text. Their text status remains `not_imported` until a specific edition, source URL, licence, recension/shakha, and completeness checks have been recorded.

## Translation policy

- Sanskrit is the source text of truth.
- Hindi and English translations must be newly prepared from the verified Sanskrit source.
- A translation is not marked complete until it has been generated, checked against the Sanskrit, and reviewed.
- Do not copy modern copyrighted translations, commentaries, or publisher editorial matter.
- A public-domain ancient work does not automatically make every digital transcription or modern edition unrestricted. Verify the exact source licence and comply with attribution/share-alike/non-commercial terms.

## Release honesty

The reader must distinguish:
1. Full original text imported and verified.
2. Original text imported but numbering/edition review pending.
3. Introductory material only.
4. Text not yet imported.

Do not describe the whole library as complete while any of its constituent works remain in states 2–4.
