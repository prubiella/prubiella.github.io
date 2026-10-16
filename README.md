# paurubiella.com

Personal website of Pau Rubiella Galindo: profile, CV and blog. Built with [Jekyll](https://jekyllrb.com/) and the [al-folio](https://github.com/alshedivat/al-folio) template (v1.2), and hosted on GitHub Pages.

## Content

| What                | Where                                                         |
| ------------------- | ------------------------------------------------------------- |
| Profile (home page) | `_pages/about.md`, `assets/img/prof_pic.jpg`                  |
| CV                  | `assets/json/resume.json` (JSON Resume), PDF in `assets/pdf/` |
| Blog posts          | `_posts/YYYY-MM-DD-title.md`                                  |
| Social links        | `_data/socials.yml`                                           |
| Site settings       | `_config.yml`                                                 |

The template's demo pages and collections (projects, publications, news, books, teaching, etc.) stay in the repo but are not published: they are listed under `exclude` and have `output: false` in `_config.yml`. Its demo posts are in `_drafts/`.

## Local development

Requires Docker and the shared Traefik from `freaksheep-dev/localstack` (network `traefik_lb_network`).

```bash
make setup-hostname   # once: adds prubiella.traefik.local to /etc/hosts
make build            # builds the image as your user
make start            # http://prubiella.traefik.local and http://127.0.0.1:8082
make logs             # follow Jekyll; pages rebuild on save, _config.yml changes restart Jekyll
make stop
```

## Deployment

Pushing to `master` runs `.github/workflows/deploy.yml`, which builds the site and publishes it to the `gh-pages` branch. Pull requests build the site without deploying it, and run the link, prettier and al-folio upgrade checks.

## Customizations

Two files override the al-folio gems, and both are recorded in `.al-folio-overrides.yml`:

- `_includes/cv/experience.liquid`: CV entry layout, and HTML summaries rendered as HTML.
- `assets/css/main.scss`: dark blue accent colour in the light theme.

`feed.xml` is a local copy of jekyll-feed's template, so that the feed title is the full name instead of `blank`.

## Updating al-folio

al-folio v1.x ships its layouts and styles as gems pinned in the `Gemfile`. To update:

1. Read the release notes and update the gem pins in the `Gemfile` (and `plugins` in `_config.yml` for new gems).
2. `make build && make start`, then `make audit`.
3. Review any override the audit flags with `bundle exec al-folio upgrade overrides diff <path>`, and accept it with `bundle exec al-folio upgrade overrides accept <path>`.
