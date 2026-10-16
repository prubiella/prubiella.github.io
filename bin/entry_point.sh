#!/bin/bash
set -euo pipefail

echo "Entry point script running"

CONFIG_FILE=_config.yml
DOCKER_DESTINATION=/tmp/_site

# Function to manage Gemfile.lock
manage_gemfile_lock() {
    git config --global --add safe.directory /srv/jekyll
    if command -v git &> /dev/null && [ -f Gemfile.lock ]; then
        if git ls-files --error-unmatch Gemfile.lock &> /dev/null; then
            echo "Gemfile.lock is tracked by git, keeping it intact"
            git restore Gemfile.lock 2>/dev/null || true
        else
            echo "Gemfile.lock is not tracked by git, removing it"
            rm Gemfile.lock
        fi
    fi
}

ensure_bundle_deps() {
    if bundle check >/dev/null 2>&1; then
        echo "Bundler dependencies already satisfied"
        return
    fi

    echo "Installing missing bundler dependencies"
    bundle install --jobs 4 --retry 3
}

start_jekyll() {
    manage_gemfile_lock
    ensure_bundle_deps
    mkdir -p "$DOCKER_DESTINATION"
    bundle exec jekyll serve --watch --port=8080 --host=0.0.0.0 --livereload --verbose --trace --force_polling --destination "$DOCKER_DESTINATION" --config "$CONFIG_FILE" &
}

start_jekyll

# Watch the directory, not the file: editors and `sed -i` replace _config.yml with a new file, which ends a
# watch on the file itself, and under `set -e` the failing inotifywait used to stop the container.
while true; do
    changed=$(inotifywait -q -e close_write,moved_to,create --format '%f' . || true)
    if [ "$changed" = "$CONFIG_FILE" ]; then
        echo "Change detected to $CONFIG_FILE, restarting Jekyll"
        # match "jekyll serve" only: a bare "jekyll" also matches this script (/srv/jekyll/bin/entry_point.sh)
        # and killed the container on every config change
        pkill -KILL -f "jekyll serve" || true
        start_jekyll
    fi
done
