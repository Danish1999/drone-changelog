#!/bin/bash

if [ -z "$PLUGIN_OUTPUT" ]; then
    PLUGIN_OUTPUT="changelog.txt"
fi

# Check cache for previous commit hash
LAST_COMMIT="$SEMAPHORE_CACHE_DIR/.last_commit"
if [ -f "$LAST_COMMIT" ]; then
    PREV_COMMIT_SHA="$(cat $LAST_COMMIT)"
else
    mkdir -p $SEMAPHORE_CACHE_DIR
    echo $COMMIT_SHA > $LAST_COMMIT
fi

# Put local copy of last commit in working directory
echo $PREV_COMMIT_SHA > .last_commit

# Set commit range for git log, from previous commit to latest
GIT_COMMIT_RANGE="$PREV_COMMIT_SHA..$COMMIT_SHA"
GIT_COMMIT_LOG="$(git log --format='%s (by %an)' $GIT_COMMIT_RANGE)"

# Check if log isn't empty, otherwise rebuild cache and exit
if [ -z "$GIT_COMMIT_LOG" ]
then
    echo "No changelog found, skipping cache restore and rebuild!"

    # Save commit message to changelog and overwrite cache
    echo $COMMIT_MESSAGE > $PLUGIN_OUTPUT
    echo $COMMIT_SHA > $LAST_COMMIT

    # Let other plugins/scripts know that this is a clean build
    touch .clean
    exit 0
fi

# Parse log and output generated changelog to output file
touch $PLUGIN_OUTPUT
printf '%s\n' "$GIT_COMMIT_LOG" | while IFS= read -r line
do
    echo "- ${line}" >> $PLUGIN_OUTPUT
done

# Print out changelog
echo "Changelog for build:"
cat $PLUGIN_OUTPUT

# Save current commit hash to cache
echo $
COMMIT_SHA > $LAST_COMMIT
