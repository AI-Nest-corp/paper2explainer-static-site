#!/bin/bash

# Analytics Verification Script for Paper2Explainer
# Checks the status of enhanced analytics setup across all paper pages

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header "Analytics Verification Report"

# Check if shared script exists
if [ -f "js/analytics-enhanced.js" ]; then
    print_success "Shared analytics script exists: js/analytics-enhanced.js"
else
    print_error "Shared analytics script missing: js/analytics-enhanced.js"
    exit 1
fi

# Find all paper files
paper_files=($(find papers -name "index.html" | sort))
total_papers=${#paper_files[@]}

if [ $total_papers -eq 0 ]; then
    print_error "No paper files found"
    exit 1
fi

print_header "Paper Analysis"
echo "Total paper files: $total_papers"

# Count files with different states
has_ga=0
has_enhanced=0
missing_ga=0
has_title=0

echo ""
echo "Checking each paper..."

for file in "${paper_files[@]}"; do
    paper_name=$(basename $(dirname "$file"))
    
    # Check for Google Analytics
    if grep -q "gtag.*G-N7SLXFTVBP" "$file"; then
        ((has_ga++))
        
        # Check for enhanced analytics
        if grep -q "analytics-enhanced.js" "$file"; then
            ((has_enhanced++))
            status="✓ Enhanced"
        else
            status="⚠ Basic GA only"
        fi
    else
        ((missing_ga++))
        status="✗ No GA"
    fi
    
    # Check for paper title element
    if grep -q '<h1 class="title">' "$file"; then
        ((has_title++))
    else
        status="$status (No title element)"
    fi
    
    printf "  %-15s %s\n" "$paper_name" "$status"
done

print_header "Summary Statistics"
echo "Papers with Google Analytics: $has_ga/$total_papers"
echo "Papers with enhanced analytics: $has_enhanced/$total_papers"
echo "Papers missing Google Analytics: $missing_ga/$total_papers"
echo "Papers with title element: $has_title/$total_papers"

# Calculate percentages
if [ $total_papers -gt 0 ]; then
    enhanced_percent=$((has_enhanced * 100 / total_papers))
    echo "Enhanced analytics coverage: $enhanced_percent%"
fi

print_header "Recommendations"

if [ $missing_ga -gt 0 ]; then
    print_warning "$missing_ga papers are missing Google Analytics entirely"
    echo "  → Add the basic GA tracking code to these papers first"
fi

if [ $has_enhanced -lt $has_ga ]; then
    remaining=$((has_ga - has_enhanced))
    print_warning "$remaining papers have GA but not enhanced analytics"
    echo "  → Run ./add-analytics.sh to add enhanced tracking"
fi

if [ $has_title -lt $total_papers ]; then
    missing_titles=$((total_papers - has_title))
    print_warning "$missing_titles papers are missing <h1 class=\"title\"> elements"
    echo "  → Paper titles won't be captured for these pages"
fi

if [ $has_enhanced -eq $total_papers ] && [ $has_title -eq $total_papers ]; then
    print_success "All papers have enhanced analytics and title elements!"
    echo ""
    echo "Test your setup:"
    echo "1. Open a paper page in your browser"
    echo "2. Open Developer Tools (F12) → Network tab"
    echo "3. Reload the page"
    echo "4. Look for requests to google-analytics.com with paper_title parameters"
    echo ""
    echo "Monitor in Google Analytics:"
    echo "1. Go to Reports → Realtime → Events"
    echo "2. Look for 'paper_view' events"
    echo "3. Check event parameters for paper titles"
fi

print_header "Quick Commands"
echo "List papers with enhanced analytics:"
echo "  find papers -name 'index.html' -exec grep -l 'analytics-enhanced.js' {} \\;"
echo ""
echo "List papers needing enhanced analytics:"
echo "  find papers -name 'index.html' -exec grep -L 'analytics-enhanced.js' {} \\;"
echo ""
echo "Test enhanced analytics script:"
echo "  curl -s http://localhost:8000/js/analytics-enhanced.js | head -5"