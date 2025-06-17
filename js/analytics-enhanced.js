// Enhanced Google Analytics tracking for Paper2Explainer
// Sends paper title as custom parameter when page loads

window.addEventListener('load', function() {
  // Get paper title from the h1 element
  const paperTitleElement = document.querySelector('h1.title');
  const paperTitle = paperTitleElement ? paperTitleElement.textContent.trim() : 'Unknown Paper';
  
  // Get paper ID from URL (e.g., "2506.02153" from the path)
  const pathParts = window.location.pathname.split('/');
  const paperIdIndex = pathParts.indexOf('papers') + 1;
  const paperId = paperIdIndex > 0 && paperIdIndex < pathParts.length ? pathParts[paperIdIndex] : 'unknown';
  
  // Send page view with paper information as custom parameters
  gtag('event', 'page_view', {
    'paper_title': paperTitle,
    'paper_id': paperId,
    'content_group1': paperTitle, // This will show up in Content Grouping in GA
    'content_group2': paperId,    // Secondary grouping by paper ID
    'custom_map': {
      'paper_title': paperTitle,
      'paper_id': paperId
    }
  });

  // Also send a custom event for paper views specifically
  gtag('event', 'paper_view', {
    'paper_title': paperTitle,
    'paper_id': paperId,
    'event_category': 'Paper',
    'event_label': paperTitle
  });
});