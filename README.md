# CGCRB bilingual guideline mock

A local Jekyll / Minimal Mistakes demonstration for a Chinese rare book cataloging
guideline. **All guideline text is demonstration content, not approved guidance.**

## Run locally

Use the Ruby version in `.ruby-version`, then:

```sh
bundle install
bundle exec ruby scripts/validate.rb
bundle exec jekyll serve --host 127.0.0.1
```

Open `http://127.0.0.1:4000/cgcrb/`. Restart the server after configuration changes.

## Structure

- `index.html`: bilingual overview and chapter directory.
- `_data/navigation.yml`: chapter and section navigation.
- `guideline/*.md`: section pages, rule order, displayed numbers, and heading levels.
- `_zh/*.md` and `_en/*.md`: paired Markdown with a common `rule_id`.
- `_layouts/bilingual.html`: paired rule layout, extending `single` and the theme's `default` layout.
- `assets/css/bilingual.css`: site appearance, responsive columns, and print styles.
- `assets/js/manual.js`: mobile contents, printing, and static search.
- `search-index.json`: generated bilingual search data.

The four levels are chapter (`h1`), section (`h2`), rule (`h3`), and subrule (`h4`).
At widths below 900 CSS pixels, Chinese and English stack within each rule.

## Content and source files

The 18 demonstration rule pairs include lists, quotations, rare Unicode
characters, and preformatted examples. Replace their contents only after the
user's final Chinese and English versions are supplied and mapped.

Keep supplied originals in `source/` or `original-documents/`, which are excluded
from the build. If files arrive elsewhere, add their actual paths to `exclude`
before building. Do not overwrite the originals or publish them unintentionally.

## Validate and build

```sh
bundle exec ruby scripts/validate.rb
JEKYLL_ENV=production bundle exec jekyll build
bundle exec ruby scripts/check_site.rb
```

The generated website is in `_site/`; do not commit build output.

## GitHub Pages

Website: <https://yishan-png.github.io/cgcrb/>

Repository: <https://github.com/yishan-png/cgcrb>

The GitHub Actions workflow in `.github/workflows/pages.yml` validates the
bilingual content, builds Jekyll, checks generated links, and deploys successful
builds from `main`. Pull requests run the checks without deploying. The Pages
source in repository settings must be GitHub Actions.

`url` is `https://yishan-png.github.io`, and `baseurl` is `/cgcrb`.
After changing Markdown or layout files, commit and push to `main` to update the
published mock. Monitor the repository's Actions tab for build and deployment
results. A failed build leaves the last successfully deployed version online.

Keep the demonstration notice until all placeholder text is replaced and reviewed.
