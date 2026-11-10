# Ved Rahasya — Research and Content Roadmap

## Product goal
Build a Hindi-first, source-attributed Sanatana Dharma learning app for beginners and serious readers. The app must distinguish primary scripture text, editorial explanation, traditional commentary, and modern interpretation.

## Content principles
1. Preserve the Sanskrit source text and verse/section numbering of the selected edition.
2. Every content item records its source, edition/recension where applicable, language, editor/translator, rights/license status, and last verification date.
3. Never present a modern interpretation as the only or universally accepted meaning. Where traditions differ, show clearly labelled viewpoints.
4. Do not reproduce copyrighted translations, commentaries, audio, images, or recordings without permission or a verified license. Indian copyright terms depend on the work and author/publication facts; check each item individually.
5. For Vedic texts, identify the Veda, shakha/recension, samhita and mantra locator. Do not flatten variant recensions into one unlabelled text.
6. Keep claims about science, medicine, astronomy, history, and ritual in their proper context; distinguish scripture, traditional interpretation, and modern evidence.

## Research source strategy
- Primary discovery and Vedic structure: Ministry of Culture / IGNCA Vedic Heritage Portal (https://vedicheritage.gov.in/), including Samhitas, Brahmanas, Aranyakas, Upanishads, Vedangas, rituals, oral recitation traditions, manuscripts and learning centres.
- Legal rights: Government of India Copyright Office / IP India guidance (https://ipindia.gov.in/pages/copyright/learn/basics-of-copyright) and Copyright Act, 1957. Verify rights per edition, translation, recording, image and commentary.
- For each scripture, select a clearly identified Sanskrit base edition and cross-check text and numbering against at least one independent scholarly or institutional source before publication.
- Record bibliographic metadata and source links inside the app; do not rely on search snippets as the sole verification.

## Content modules and release order

### Release 1 — Bhagavad Gita (first complete scripture module)
- 18 chapter index with traditional chapter names and verse counts verified against the chosen edition.
- Verse reader: Devanagari Sanskrit, optional transliteration, word-by-word gloss, literal translation, plain Hindi meaning, deeper explanation, context, cross-references, source/edition.
- Chapter introduction, key themes, learning objectives, related verses, bookmarks, notes, reading progress, text-size controls and offline access.
- Start with a reviewed sample chapter and expand chapter-by-chapter; never label the full Gita complete until all verses are verified.

### Release 2 — Ten principal Upanishads
- Start with Isha, Kena, Katha, Prashna, Mundaka, Mandukya, Taittiriya, Aitareya, Chandogya and Brihadaranyaka.
- Each text includes structure, mantra locator, Sanskrit text, word meanings, translation, explanation, philosophical concepts and source/edition.
- Clearly label recension and commentary tradition where relevant.

### Release 3 — Vedic knowledge library
- Rigveda, Yajurveda, Samaveda and Atharvaveda: explain structure, shakhas, samhitas, Brahmanas, Aranyakas, associated Upanishads and Vedangas.
- Build a structured catalogue first; add actual mantra text only when the recension, source and rights are verified.
- Include recitation/audio only from sources with documented permission or an open license.

### Release 4 — Supporting knowledge
- Ramayana, Mahabharata, selected Puranic narratives, Darshanas, Yoga, Sanskrit concepts, dharma, karma, bhakti, meditation and ritual explainers.
- Keep source text, tradition-specific interpretation and modern educational commentary visibly separate.

### Release 5 — Practice and learning
- Mantra/japa counter with local persistence and optional mala rounds.
- Guided reading plans, daily learning, quizzes with answer explanations, notes, bookmarks, search, offline packs and accessibility.
- No medical, astrological, or guaranteed-outcome claims presented as established fact.

## App information architecture
- Home: continue reading, daily verse, learning path, recently opened, saved items.
- Library: Gita, Upanishads, Vedas, Itihasa, Puranas, Darshana, Yoga and practices.
- Reader: chapter/section navigation, Sanskrit text, word meanings, translation, explanation, references, audio (licensed), notes and bookmarks.
- Search: full-text search by Sanskrit/Hindi/English, scripture, chapter, verse and topic.
- Sadhana: japa, meditation timer and user-defined practice logs.
- Profile/settings: language, script/font size, theme, offline downloads, privacy and progress.

## Technical work required
- Replace the current hard-coded demo sections with structured content models and bundled, versioned content data.
- Persist bookmarks, notes, reading progress and japa count locally.
- Add search indexing, content attribution screens, offline support, tests and accessible typography.
- Add a content update mechanism only after source, licensing, versioning and moderation processes are in place.
- Keep the app usable without account creation; make cloud sync optional.

## Definition of done
A module is complete only when its scope is explicit, all included text and numbering are cross-checked, every translation/audio/image has a recorded rights status, source attribution is visible in-app, navigation and offline behaviour are tested, and the APK passes automated build plus on-device review.
