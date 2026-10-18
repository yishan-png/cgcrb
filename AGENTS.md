# Project instructions

## Purpose and agreed approach

Build a static reference website for guidelines for cataloging Chinese rare books
in North America. Use <https://bsc.rbms.info/DCRMR/> as a reference for navigation
and reference-manual presentation. Use this project's own identity and content.

- Stack: Jekyll 4.4, the Minimal Mistakes gem theme, and GitHub Pages.
- Publication: a GitHub Actions workflow builds and deploys the generated site.
- Languages: Traditional Chinese and English appear on the same webpage.
- Layout: Chinese on the left, English on the right, aligned by numbered rule.
- Authoring: Markdown files maintained in GitHub; no CMS or backend is needed.

## Current state

At the time these instructions were created, the project contains `Gemfile` and
`Gemfile.lock`. Dependencies have been installed and their loading verified:

- Jekyll 4.4.1
- Minimal Mistakes 4.28.1
- jekyll-include-cache 0.3.1
- WEBrick 1.9.2

The active local Ruby was 4.0.1, managed by rbenv. Inspect the current environment
before changing it. A full site build has not yet been verified. Use Bundler and
the existing lockfile; do not upgrade dependencies merely to start the project.

The user will supply both language versions in the project folder. Inspect the
actual files before choosing an import method. These instructions describe the
target implementation; do not assume its files already exist.

## Handling the supplied content

- Preserve original source files and their wording. Create web-ready derivatives
  without overwriting or deleting the supplied files.
- Treat both supplied versions as authoritative. Do not translate, paraphrase,
  modernize characters, or silently correct cataloging instructions.
- Preserve numbering, examples, romanization, punctuation, rare characters,
  references, and meaningful formatting. Keep text selectable and UTF-8 encoded.
- Match translations by rule number and document structure, not by paragraph
  count. If pairing is ambiguous, identify the affected rules and ask the user.
- Do not invent missing rules, translations, institutional affiliations, or
  publication metadata. Report missing counterparts explicitly.
- Before sources arrive, scaffolding may use clearly marked demonstration text.
  Demonstrations must not be presented as approved guidance or left in the
  published edition.

## Target structure and content model

```text
.github/workflows/pages.yml   # Build checks and GitHub Pages deployment
.ruby-version                # Ruby version shared by local development and CI
.gitignore
Gemfile
Gemfile.lock
_config.yml
_data/navigation.yml
_layouts/bilingual.html
_includes/head/custom.html
_zh/                         # Chinese rule Markdown files
_en/                         # English rule Markdown files
guideline/                   # Published section pages
assets/css/bilingual.css
assets/images/
index.md
```

- Configure `zh` and `en` as Jekyll collections with `output: false`.
- Store each rule as a Chinese and English Markdown file with matching `rule_id`
  front matter and a language-specific `title`.
- Store each published section as a page using the `bilingual` layout and an
  explicit permalink. Its `rules` list contains each rule's `id` and displayed
  `number`, in reading order.
- Keep stable identifiers separate from displayed numbering. Give each paired
  rule an anchor such as `rule-1-1`; avoid generating permanent anchors from
  translated headings.
- Render one page per section, containing several paired rules. Do not generate
  separate public language pages in the initial version.
- Use the collection documents' Markdown content in the shared template rather
  than embedding layout HTML throughout the guideline source.

## Layout and navigation

- Extend Minimal Mistakes with a custom `bilingual` layout based on its `single`
  layout, using wide pages to leave adequate space for both languages.
- Render a shared numbered heading followed by a CSS Grid row with two equal
  columns. Each row contains an entire rule and its associated examples.
- Let the taller language passage determine row height so the next rule starts
  aligned. Do not use fixed heights or independent scrolling language panels.
- Below 900 CSS pixels, stack each Chinese/English pair in that order. Print
  styles should also use stacked pairs.
- Label the languages visibly and set `lang="zh-Hant"` and `lang="en"` on their
  respective containers. Preserve heading hierarchy and keyboard usability.
- Use Chinese-capable font fallbacks. Check rare-character rendering against
  the supplied examples; do not replace unsupported characters with images.
- Make images responsive and long code or MARC examples horizontally scrollable
  within their containers without overflowing the page.
- Provide a bilingual homepage/table of contents, section navigation,
  previous/next links, and direct links to numbered rules.
- Keep navigation compact so it does not crowd the bilingual text.
- Load custom CSS through `_includes/head/custom.html`. Override only necessary
  theme files rather than copying the entire theme into this repository.

## Search

Implement lightweight static search after the core layout and navigation work.

- Generate a JSON index at build time containing rule identifiers, displayed
  numbers, bilingual titles, plain text from both versions, and rule URLs.
- Generate valid JSON with proper escaping; use Jekyll's `jsonify` filter rather
  than interpolating raw text into JSON strings.
- Use browser JavaScript for English case-insensitive and Chinese substring
  matching, including rule-number lookup. Render excerpts as text, not raw HTML.
- Link results directly to paired rule anchors and show bilingual titles.
- Keep all guideline content and navigation usable without JavaScript.

## Configuration and deployment

- Configure `theme: minimal-mistakes-jekyll` and enable `jekyll-include-cache`.
- Set `url` to the actual GitHub Pages origin and `baseurl` to the repository
  path. The planned repository name is `cgcrb`; the GitHub owner is not yet known.
  Do not invent an owner or claim a live URL before it is configured.
- Use `relative_url` for internal links and assets, including search resources.
- Exclude original source documents and development files from generated output
  unless the user intends them to be public downloads.
- Ignore `_site/`, `.jekyll-cache/`, `.jekyll-metadata`, `.bundle/`, and `vendor/`.
- Commit `Gemfile.lock`. Record a verified Ruby version in `.ruby-version` and
  use it in CI through `ruby/setup-ruby` with Bundler caching.
- Run validation and production builds on pull requests and pushes to `main`.
- Deploy only successful builds from `main`, or manual runs targeting `main`;
  pull requests must not deploy to the live site.
- Use GitHub's Pages artifact upload and deployment actions, a `github-pages`
  environment, and deployment-job permissions `pages: write` and
  `id-token: write`. Keep other jobs read-only and verify current action versions
  against official documentation when implementing the workflow.
- Configure the repository's Pages source as GitHub Actions when deployment is
  requested. Building locally does not require creating a remote repository.

## Implementation sequence

1. Inspect the supplied files and map matching rules without changing originals.
2. Configure Jekyll, the theme, ignore rules, Ruby version, and local preview.
3. Implement paired Markdown collections and one representative section.
4. Build the responsive bilingual template, homepage, and navigation.
5. Import the remaining supplied content and validate pairing and links.
6. Add static bilingual search and print styling.
7. Add automated checks and the Pages workflow; verify the production build.
8. Configure and verify live publication when requested.

## Verification and completion

Use `bundle check`, `bundle exec jekyll serve`, and
`JEKYLL_ENV=production bundle exec jekyll build` for local verification. With the
planned base path, the local preview is `http://localhost:4000/cgcrb/`. Restart
Jekyll after changing `_config.yml`.

Add a small Ruby validation script, using existing dependencies, that rejects:

- Duplicate rule identifiers within either language collection.
- Missing language counterparts or missing required metadata.
- Section references to nonexistent rules and repeated anchors on one page.

Check generated internal links and fragment targets. Test that links, images,
styles, and search work under `/cgcrb/`, not only at the origin root.

Visually check desktop, mobile, 200% zoom, keyboard navigation, and print output.
Include unequal translation lengths, long examples, and rare characters in the
checks. Verify searches using both languages and rule numbers. Confirm the
generated site excludes supplied originals that are not intended for download.

Report what was changed, what was actually verified, and any remaining blockers.
Do not claim full publication or compatibility solely because gems installed or
a workflow file was created.
