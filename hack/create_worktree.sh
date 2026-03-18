#!/bin/bash

# create_worktree.sh - Create a new worktree for development work

set -e  # Exit on any error

usage() {
    echo "Usage: $(basename "$0") [options] [worktree_name] [base_branch]"
    echo ""
    echo "Create a git worktree with Claude Code configuration."
    echo ""
    echo "Arguments:"
    echo "  worktree_name    Name for the worktree/branch (auto-generated if omitted)"
    echo "  base_branch      Branch to create from (current branch if omitted)"
    echo ""
    echo "Options:"
    echo "  --no-thoughts    Skip humanlayer thoughts initialization"
    echo "  -h, --help       Show this help message"
    echo ""
    echo "Environment:"
    echo "  WORKTREE_OVERRIDE_BASE"
    echo "                   Override default worktree location (~/wt/<repo>)"
    echo ""
    echo "What it does:"
    echo "  1. Creates git worktree at ~/wt/<repo>/<worktree_name>"
    echo "  2. Copies .claude/ directory to new worktree"
    echo "  3. Copies .env* files to new worktree"
    echo "  4. Runs 'make setup' if available"
    echo "  5. Initializes humanlayer thoughts (unless --no-thoughts)"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0")                    # Auto-generated name, current branch"
    echo "  $(basename "$0") my-feature         # Named worktree from current branch"
    echo "  $(basename "$0") my-feature main    # Named worktree from main branch"
    echo "  $(basename "$0") --no-thoughts fix  # Skip thoughts initialization"
}

# Function to generate a unique worktree name
generate_unique_name() {
    local adjectives=("swift" "bright" "clever" "smooth" "quick" "clean" "sharp" "neat" "cool" "fast")
    local nouns=("fix" "task" "work" "dev" "patch" "branch" "code" "build" "test" "run")

    local adj=${adjectives[$RANDOM % ${#adjectives[@]}]}
    local noun=${nouns[$RANDOM % ${#nouns[@]}]}
    local timestamp=$(date +%H%M)

    echo "${adj}_${noun}_${timestamp}"
}

# Parse flags
INIT_THOUGHTS=true
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --no-thoughts)
            INIT_THOUGHTS=false
            shift
            ;;
        *)
            break
            ;;
    esac
done

# Get worktree name from parameter or generate one
WORKTREE_NAME=${1:-$(generate_unique_name)}

# Get base branch from second parameter or use current branch
BASE_BRANCH=${2:-$(git branch --show-current)}

# Get base directory name (For example 'ai-playbook' or 'platform' or whatever the repo name is)
REPO_BASE_NAME=$(basename "$(pwd)")

# Convert / to __ for flat directory structure
WORKTREE_DIR_NAME="${WORKTREE_NAME//\//__}"

if [ ! -z "$WORKTREE_OVERRIDE_BASE" ]; then
    WORKTREES_BASE="${WORKTREE_OVERRIDE_BASE}/${REPO_BASE_NAME}"
else
    WORKTREES_BASE="$HOME/wt/${REPO_BASE_NAME}"
fi

WORKTREE_PATH="${WORKTREES_BASE}/${WORKTREE_DIR_NAME}"

echo "🌳 Creating worktree: ${WORKTREE_NAME}"
echo "📁 Location: ${WORKTREE_PATH}"

# Check if worktrees base directory exists
if [ ! -d "$WORKTREES_BASE" ]; then
    echo "❌ Error: Directory $WORKTREES_BASE does not exist."
    echo "   Please create it first: mkdir -p $WORKTREES_BASE"
    exit 1
fi

# Check if worktree already exists
if [ -d "$WORKTREE_PATH" ]; then
    echo "❌ Error: Worktree directory already exists: $WORKTREE_PATH"
    exit 1
fi

# Display base branch info
echo "🔀 Creating from branch: ${BASE_BRANCH}"

# Create worktree (creates branch if it doesn't exist)
if git show-ref --verify --quiet "refs/heads/${WORKTREE_NAME}"; then
    echo "📋 Using existing branch: ${WORKTREE_NAME}"
    git worktree add "$WORKTREE_PATH" "$WORKTREE_NAME"
else
    echo "🆕 Creating new branch: ${WORKTREE_NAME}"
    git worktree add -b "$WORKTREE_NAME" "$WORKTREE_PATH" "$BASE_BRANCH"
fi

# Copy .claude directory if it exists
if [ -d ".claude" ]; then
    echo "📋 Copying .claude directory..."
    cp -r .claude "$WORKTREE_PATH/"
fi

# Copy .env files if they exist
if ls .env* 1> /dev/null 2>&1; then
    echo "📋 Copying .env files..."
    for env_file in .env*; do
        if [[ -f "$env_file" ]]; then
            cp "$env_file" "$WORKTREE_PATH/"
            echo "   Copied: $env_file"
        fi
    done
fi

# Copy settings-mine* files preserving directory structure
echo "📋 Copying settings-mine files..."
SETTINGS_FOUND=false
while IFS= read -r -d '' settings_file; do
    SETTINGS_FOUND=true
    relative_path="${settings_file#./}"
    dest_path="$WORKTREE_PATH/$relative_path"
    mkdir -p "$(dirname "$dest_path")"
    cp "$settings_file" "$dest_path"
    echo "   Copied: $relative_path"
done < <(find . -type f \( -name "settings-mine*.js" -o -name "settings-mine*.json" \) -print0 2>/dev/null)

if [ "$SETTINGS_FOUND" = false ]; then
    echo "   No settings-mine files found"
fi

# Change to worktree directory
cd "$WORKTREE_PATH"

# Run make setup if Makefile exists and has setup target
if [[ -f "Makefile" ]] && grep -q "^setup:" Makefile; then
    echo "🔧 Running make setup..."
    if ! make setup; then
        echo "⚠️  make setup failed. You may need to set up manually."
        echo "   Continuing with worktree creation..."
    fi
else
    echo "ℹ️  No Makefile setup target found. Skipping automatic setup."
fi

# echo "🧪 Verifying worktree with checks and tests..."
# temp_output=$(mktemp)
# if make check test > "$temp_output" 2>&1; then
#     rm "$temp_output"
#     echo "✅ All checks and tests pass!"
# else
#     cat "$temp_output"
#     rm "$temp_output"
#     echo "❌ Checks and tests failed. Cleaning up worktree..."
#     cd - > /dev/null
#     git worktree remove --force "$WORKTREE_PATH"
#     git branch -D "$WORKTREE_NAME" 2>/dev/null || true
#     echo "❌ Not allowed to create worktree from a branch that isn't passing checks and tests."
#     exit 1
# fi

# Initialize thoughts (non-interactive mode with hardcoded directory)
if [ "$INIT_THOUGHTS" = true ]; then
    echo "🧠 Initializing thoughts..."
    cd "$WORKTREE_PATH"
    if humanlayer thoughts init --directory "$REPO_BASE_NAME" > /dev/null 2>&1; then
        echo "✅ Thoughts initialized!"
        # Run sync to create searchable directory
        if humanlayer thoughts sync > /dev/null 2>&1; then
            echo "✅ Thoughts searchable index created!"
        else
            echo "⚠️  Could not create searchable index. Run 'humanlayer thoughts sync' manually."
        fi
    else
        echo "⚠️  Could not initialize thoughts automatically. Run 'humanlayer thoughts init' manually."
    fi
fi

# Return to original directory
cd - > /dev/null

echo "✅ Worktree created successfully!"
echo "📁 Path: ${WORKTREE_PATH}"
echo "🔀 Branch: ${WORKTREE_NAME}"
echo ""
echo "To work in this worktree:"
echo "  cd ${WORKTREE_PATH}"
echo ""
echo "To remove this worktree later:"
echo "  git worktree remove ${WORKTREE_PATH}"
echo "  git branch -D ${WORKTREE_NAME}"
