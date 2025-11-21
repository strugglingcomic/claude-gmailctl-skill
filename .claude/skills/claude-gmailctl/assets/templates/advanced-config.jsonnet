// Advanced gmailctl configuration with reusable functions
// Demonstrates Jsonnet features for maintainable configuration

// ===== CONFIGURATION CONSTANTS =====
local workDomain = "company.com";
local personalEmail = "me@personal.com";

local workPrioritySenders = [
  "boss@" + workDomain,
  "ceo@" + workDomain,
  "client@important.com",
];

local newsletterSenders = [
  "newsletter@medium.com",
  "updates@substack.com",
  "news@techcrunch.com",
];

local notificationServices = [
  "notifications@github.com",
  "noreply@jira.atlassian.com",
  "notifications@slack.com",
];

// ===== HELPER FUNCTIONS =====

// Create a query matching any sender in a list
local fromAnySender(senders) =
  std.join(" OR ", ["from:" + s for s in senders]);

// Archive and label helper
local archiveAndLabel(query, label) = {
  filter: { query: query },
  actions: { archive: true, labels: [label] }
};

// Mark important and label
local prioritizeAndLabel(query, label) = {
  filter: { query: query },
  actions: { markImportant: true, labels: [label] }
};

// Auto-read and archive
local autoReadArchive(query, label) = {
  filter: { query: query },
  actions: { archive: true, markRead: true, labels: [label] }
};

// ===== MAIN CONFIGURATION =====
{
  version: "v1alpha3",

  // Label definitions
  labels: [
    // Work hierarchy
    { name: "Work" },
    { name: "Work/Priority" },
    { name: "Work/Projects" },
    { name: "Work/Team" },
    { name: "Work/Admin" },
    { name: "Work/1-on-1" },

    // Personal hierarchy
    { name: "Personal" },
    { name: "Personal/Finance" },
    { name: "Personal/Health" },
    { name: "Personal/Travel" },
    { name: "Personal/Family" },

    // Reference archives
    { name: "Reference" },
    { name: "Reference/Receipts" },
    { name: "Reference/Docs" },
    { name: "Reference/Legal" },

    // Low-priority
    { name: "Newsletters" },
    { name: "Notifications" },
    { name: "Social" },

    // Action states
    { name: "Action-Required" },
    { name: "Waiting" },
    { name: "Someday-Maybe" },
  ],

  // Filter rules
  rules: [
    // ===== CRITICAL PRIORITY =====
    prioritizeAndLabel(
      fromAnySender(workPrioritySenders),
      "Work/Priority"
    ),

    // ===== WORK CONTEXT =====
    {
      filter: { query: "from:@" + workDomain + " subject:1:1" },
      actions: { labels: ["Work/1-on-1"], markImportant: true }
    },

    {
      filter: { query: "from:@" + workDomain + " (subject:project OR subject:sprint)" },
      actions: { labels: ["Work/Projects"] }
    },

    {
      filter: { query: "from:@" + workDomain + " subject:(PTO OR OOO OR vacation)" },
      actions: { archive: true, labels: ["Work/Admin"] }
    },

    // ===== AUTO-ARCHIVE PATTERNS =====
    autoReadArchive(
      fromAnySender(newsletterSenders),
      "Newsletters"
    ),

    autoReadArchive(
      fromAnySender(notificationServices) + " -is:important",
      "Notifications"
    ),

    // ===== SOCIAL MEDIA =====
    autoReadArchive(
      "from:(twitter.com OR linkedin.com OR facebook.com)",
      "Social"
    ),

    // ===== FINANCIAL =====
    {
      filter: {
        query: "from:(bank.com OR chase.com OR amex.com OR paypal.com)"
      },
      actions: {
        labels: ["Personal/Finance"],
        markImportant: true
      }
    },

    archiveAndLabel(
      "subject:(receipt OR invoice OR order confirmation) has:attachment",
      "Reference/Receipts"
    ),

    // ===== TRAVEL =====
    {
      filter: {
        query: "from:(airlines.com OR hotel.com OR airbnb.com OR expedia.com) subject:(confirmation OR itinerary)"
      },
      actions: {
        labels: ["Personal/Travel"],
        markImportant: true
      }
    },

    // ===== HEALTH =====
    {
      filter: {
        query: "from:(doctor.com OR hospital.com OR pharmacy.com)"
      },
      actions: {
        labels: ["Personal/Health"],
        markImportant: true
      }
    },

    // ===== LEGAL/IMPORTANT DOCS =====
    {
      filter: {
        query: "subject:(contract OR agreement OR legal OR NDA) has:attachment"
      },
      actions: {
        labels: ["Reference/Legal"],
        markImportant: true
      }
    },

    // ===== BULK CLEANUP =====
    // Archive old read emails from specific senders
    {
      filter: {
        query: "from:no-reply@* is:read older_than:30d"
      },
      actions: {
        archive: true
      }
    },
  ],
}
