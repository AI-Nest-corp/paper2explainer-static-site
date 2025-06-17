# paper2explainer-static-site

Static site for paper explanations and summaries.

## Analytics Setup

This project uses enhanced Google Analytics tracking that captures paper titles and IDs as custom parameters for detailed reporting.

### Quick Setup
1. Run `./scripts/add-analytics.sh` to add enhanced tracking to all paper pages
2. Enhanced analytics automatically extracts paper titles from `<h1 class="title">` elements
3. Data is sent to Google Analytics with custom parameters: `paper_title` and `paper_id`

### Architecture
- **`/js/analytics-enhanced.js`**: Shared script for paper title tracking
- **Paper pages**: Include both standard GA code and enhancement script
- **Custom events**: `page_view` and `paper_view` with paper metadata

### What's Tracked
- Paper titles and IDs as custom parameters
- Content groupings by paper title/ID
- Enhanced page views with paper metadata

### Maintenance
When adding new papers:
1. Add files to `papers/` directory
2. Run `./scripts/add-analytics.sh` to add enhanced tracking
3. Verify with `find papers -name "index.html" -exec grep -l "analytics-enhanced.js" {} \;`

### Viewing Data
- **Real-time**: GA → Reports → Realtime
- **Events**: Reports → Engagement → Events (look for `paper_view`)
- **Content Groups**: Reports → Engagement → Pages (add "Content Group 1")