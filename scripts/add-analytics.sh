#!/bin/bash

# Enhanced Analytics Setup Script for Paper2Explainer
# Adds enhanced Google Analytics tracking with paper titles to all paper pages
# 
# Usage: ./add-analytics.sh [--dry-run] [--verbose]
#   --dry-run: Show what would be done without making changes
#   --verbose: Show detailed output

set -e  # Exit on error

# Parse command line arguments
DRY_RUN=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo "Enhanced Analytics Setup Script"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --dry-run    Show what would be done without making changes"
            echo "  --verbose    Show detailed output"
            echo "  -h, --help   Show this help message"
            echo ""
            echo "This script adds enhanced Google Analytics tracking to all paper pages."
            echo "See ANALYTICS_SETUP.md for detailed documentation."
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "Enhanced Analytics Setup for Paper2Explainer"
print_status "=============================================="

if [ "$DRY_RUN" = true ]; then
    print_warning "DRY RUN MODE - No files will be modified"
fi

# Check if the shared analytics script exists
if [ ! -f "js/analytics-enhanced.js" ]; then
    print_error "js/analytics-enhanced.js not found!"
    print_error "Please ensure the shared analytics script exists before running this."
    exit 1
fi

print_success "Found shared analytics script: js/analytics-enhanced.js"

# Find all paper index.html files
paper_files=($(find papers -name "index.html" | sort))

if [ ${#paper_files[@]} -eq 0 ]; then
    print_error "No paper files found in papers/ directory"
    exit 1
fi

print_status "Found ${#paper_files[@]} paper files"

# Counters
updated=0
skipped=0
errors=0

# Process each file
for file in "${paper_files[@]}"; do
    if [ ! -f "$file" ]; then
        print_warning "$file not found"
        ((errors++))
        continue
    fi
    
    # Check if file already has enhanced analytics
    if grep -q "analytics-enhanced.js" "$file"; then
        if [ "$VERBOSE" = true ]; then
            print_status "Skipping $file (already has enhanced analytics)"
        fi
        ((skipped++))
        continue
    fi
    
    # Check if file has Google Analytics
    if ! grep -q "gtag.*G-N7SLXFTVBP" "$file"; then
        print_warning "$file doesn't have Google Analytics - skipping"
        ((errors++))
        continue
    fi
    
    if [ "$DRY_RUN" = true ]; then
        print_status "Would update: $file"
        ((updated++))
        continue
    fi
    
    # Create backup
    cp "$file" "$file.backup"
    
    # Add the enhanced analytics script
    if sed -i '' '/gtag.*G-N7SLXFTVBP.*);/a\
</script>\
\
<!-- Enhanced Analytics with Paper Title Tracking -->\
<script src="/js/analytics-enhanced.js"></script>
' "$file"; then
        print_success "Updated: $file"
        ((updated++))
        # Remove backup if successful
        rm "$file.backup"
    else
        print_error "Failed to update: $file"
        # Restore backup
        mv "$file.backup" "$file"
        ((errors++))
    fi
done

# Print summary
echo ""
print_status "Summary"
print_status "======="
echo "Files processed: ${#paper_files[@]}"
echo "Updated: $updated"
echo "Skipped (already enhanced): $skipped"
echo "Errors: $errors"

if [ "$DRY_RUN" = true ]; then
    echo ""
    print_status "This was a dry run. Run without --dry-run to make actual changes."
elif [ $updated -gt 0 ]; then
    echo ""
    print_success "Enhanced analytics setup complete!"
    echo ""
    echo "Next steps:"
    echo "1. Test a few paper pages to ensure analytics is working"
    echo "2. Check Google Analytics for 'paper_view' events"
    echo "3. See ANALYTICS_SETUP.md for detailed usage instructions"
    echo ""
    echo "Verification commands:"
    echo "  Check enhanced pages: find papers -name 'index.html' -exec grep -l 'analytics-enhanced.js' {} \\;"
    echo "  Total enhanced: find papers -name 'index.html' -exec grep -l 'analytics-enhanced.js' {} \\; | wc -l"
fi

if [ $errors -gt 0 ]; then
    echo ""
    print_warning "Some files had errors. Check the output above for details."
    exit 1
fi