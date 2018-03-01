#!/bin/bash

if [ -z "$MAJOR_MINOR" ]; then
    MAJOR_MINOR="alpha"
fi

if [ -z "$PLUGIN_OUTPUT" ]; then
    PLUGIN_OUTPUT="changelog.txt"
fi

# Set commit range for git log, from previous commit to latest
GIT_COMMIT_RANGE="$DRONE_PREV_COMMIT_SHA..$DRONE_COMMIT_SHA"
GIT_COMMIT_LOG="$(git log --format='%s (by %cn)' $GIT_COMMIT_RANGE)"

# Check if log isn't empty, otherwise exit
if [ -z "$GIT_COMMIT_LOG" ]
then
    echo "No changelog found!" | tee $PLUGIN_OUTPUT
    exit
fi

# Parse log and output generated changelog to output file
touch $PLUGIN_OUTPUT
printf '%s\n' "$GIT_COMMIT_LOG" | while IFS= read -r line
do
    echo "- ${line}" >> $PLUGIN_OUTPUT
done

# Print out changelog
echo "Changelog for build ${MAJOR_MINOR}-${DRONE_BUILD_NUMBER}"
cat $PLUGIN_OUTPUT
echo -e "\nView on GitHub: ${DRONE_REPO_LINK}/compare/${DRONE_PREV_COMMIT_SHA}..${DRONE_COMMIT_SHA}"
