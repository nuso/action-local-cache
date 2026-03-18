#!/usr/bin/env bash
set -euo pipefail

# cleanup_worktree.sh - Clean up git worktrees with thoughts directory support
#
# Usage: ./hack/cleanup_worktree.sh [worktree_name]
#
# If no worktree name is provided, lists available worktrees to clean up

# Get the main repository root (first entry in worktree list is always the main worktree)
# Note: git rev-parse --show-toplevel returns the *current* worktree root, not the main one
MAIN_REPO=$(git worktree list | head -1 | awk '{print $1}')

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to list all worktrees (excluding the main repo)
list_worktrees() {
    echo -e "${YELLOW}Available worktrees:${NC}"
    local found=false
    while IFS= read -r line; do
        local wt_path
        wt_path=$(echo "$line" | awk '{print $1}')
        # Skip the main repository itself
        if [ "$wt_path" != "$MAIN_REPO" ]; then
            echo "$line"
            found=true
        fi
    done < <(git worktree list)

    if [ "$found" = false ]; then
        echo "No worktrees found (besides main repo)"
        return 1
    fi
}

# Function to find a worktree by user input (path, name, or branch)
# Returns the full path if found, empty string if not
find_worktree() {
    local search="$1"
    local normalized_search="${search//\//__}"

    while IFS= read -r line; do
        local wt_path
        wt_path=$(echo "$line" | awk '{print $1}')
        local wt_branch
        wt_branch=$(echo "$line" | sed -n 's/.*\[\(.*\)\].*/\1/p')

        # Skip main repo
        [ "$wt_path" = "$MAIN_REPO" ] && continue

        # Match by exact path
        [ "$wt_path" = "$search" ] && echo "$wt_path" && return 0

        # Match by directory name (last component of path)
        local dir_name
        dir_name=$(basename "$wt_path")
        [ "$dir_name" = "$search" ] && echo "$wt_path" && return 0
        [ "$dir_name" = "$normalized_search" ] && echo "$wt_path" && return 0

        # Match by branch name
        [ "$wt_branch" = "$search" ] && echo "$wt_path" && return 0

    done < <(git worktree list)

    return 1
}

# Function to clean up a specific worktree
cleanup_worktree() {
    local search_term="$1"

    # Find the worktree using discovery
    # Use || true to prevent set -e from exiting before we can show a friendly error
    local worktree_path
    worktree_path=$(find_worktree "$search_term" || true)

    if [ -z "$worktree_path" ]; then
        echo -e "${RED}Error: No worktree found matching '${search_term}'${NC}"
        echo ""
        echo "Searched by: exact path, directory name, branch name"
        echo ""
        list_worktrees
        exit 1
    fi

    # Get the branch name for this worktree
    # Use grep -F for fixed-string match (avoids regex issues with special chars in path)
    # Use || true to handle no-match without pipefail aborting the script
    local worktree_branch
    worktree_branch=$(git worktree list | grep -F "$worktree_path" | sed -n 's/.*\[\(.*\)\].*/\1/p' || true)

    echo -e "${YELLOW}Cleaning up worktree: $worktree_path${NC}"

    # Step 1: Handle thoughts directory if it exists
    if [ -d "$worktree_path/thoughts" ]; then
        echo "Found thoughts directory, cleaning up..."

        # Try to use humanlayer uninit command first
        if command -v humanlayer >/dev/null 2>&1; then
            echo "Running humanlayer thoughts uninit..."
            (cd "$worktree_path" && humanlayer thoughts uninit --force) || {
                echo -e "${YELLOW}Warning: humanlayer uninit failed, falling back to manual cleanup${NC}"

                # Fallback: Reset permissions on searchable directory if it exists
                if [ -d "$worktree_path/thoughts/searchable" ]; then
                    echo "Resetting permissions on thoughts/searchable..."
                    chmod -R 755 "$worktree_path/thoughts/searchable" 2>/dev/null || {
                        echo -e "${YELLOW}Warning: Could not reset all permissions, but continuing...${NC}"
                    }
                fi

                # Remove the entire thoughts directory
                echo "Removing thoughts directory..."
                rm -rf "$worktree_path/thoughts" || {
                    echo -e "${RED}Error: Could not remove thoughts directory${NC}"
                    echo "You may need to manually run: sudo rm -rf $worktree_path/thoughts"
                    exit 1
                }
            }
        else
            # No humanlayer command available, do manual cleanup
            echo "humanlayer command not found, using manual cleanup..."

            # Reset permissions on searchable directory if it exists
            if [ -d "$worktree_path/thoughts/searchable" ]; then
                echo "Resetting permissions on thoughts/searchable..."
                chmod -R 755 "$worktree_path/thoughts/searchable" 2>/dev/null || {
                    echo -e "${YELLOW}Warning: Could not reset all permissions, but continuing...${NC}"
                }
            fi

            # Remove the entire thoughts directory
            echo "Removing thoughts directory..."
            rm -rf "$worktree_path/thoughts" || {
                echo -e "${RED}Error: Could not remove thoughts directory${NC}"
                echo "You may need to manually run: sudo rm -rf $worktree_path/thoughts"
                exit 1
            }
        fi
    fi

    # Step 2: Remove the worktree
    echo "Removing git worktree..."
    if git worktree remove --force "$worktree_path"; then
        echo -e "${GREEN}✓ Worktree removed successfully${NC}"
    else
        echo -e "${RED}Error: Failed to remove worktree${NC}"
        echo "The worktree might be in an inconsistent state."
        echo ""
        echo "Try manually running:"
        echo "  rm -rf $worktree_path"
        echo "  git worktree prune"
        exit 1
    fi

    # Step 3: Delete the branch (optional, with confirmation)
    if [ -n "$worktree_branch" ]; then
        echo ""
        read -p "Delete the branch '$worktree_branch'? (y/N) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if git branch -D "$worktree_branch" 2>/dev/null; then
                echo -e "${GREEN}✓ Branch deleted${NC}"
            else
                echo -e "${YELLOW}Branch might not exist or already deleted${NC}"
            fi
        else
            echo "Branch kept: $worktree_branch"
        fi
    fi

    # Step 4: Prune worktree references
    echo "Pruning worktree references..."
    git worktree prune

    echo ""
    echo -e "${GREEN}✓ Cleanup complete!${NC}"
}

# Main logic
if [ $# -eq 0 ]; then
    # No arguments provided, list worktrees
    list_worktrees || exit 1
    echo ""
    echo "Usage: $0 <identifier>"
    echo ""
    echo "Identifier can be:"
    echo "  - Full path:      ~/wt/repo/feature__branch"
    echo "  - Directory name: feature__branch"
    echo "  - Branch name:    feature/branch"
    echo ""
    echo "The script searches git worktree list to find matches."
else
    # Worktree name provided
    cleanup_worktree "$1"
fi
