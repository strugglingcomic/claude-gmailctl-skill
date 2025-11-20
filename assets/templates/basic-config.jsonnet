// Basic gmailctl configuration example
// This demonstrates a simple Inbox Zero setup with automated triage

{
  version: "v1alpha3",

  // Define label structure
  labels: [
    // Work categories
    { name: "Work" },
    { name: "Work/Projects" },
    { name: "Work/Team" },
    { name: "Work/Admin" },

    // Personal categories
    { name: "Personal" },
    { name: "Personal/Finance" },
    { name: "Personal/Travel" },

    // Reference and archives
    { name: "Reference" },
    { name: "Reference/Receipts" },
    { name: "Reference/Docs" },

    // Low-priority content
    { name: "Newsletters" },
    { name: "Notifications" },

    // Action tracking
    { name: "Action-Required" },
    { name: "Waiting" },
  ],

  // Define filter rules
  rules: [
    // ===== HIGH PRIORITY =====
    // Important work emails stay in inbox
    {
      filter: {
        query: "from:boss@company.com OR from:ceo@company.com",
      },
      actions: {
        markImportant: true,
        labels: ["Work/Priority"],
      },
    },

    // ===== AUTO-ARCHIVE NEWSLETTERS =====
    {
      filter: {
        query: "from:newsletter@example.com OR list:updates@service.com",
      },
      actions: {
        archive: true,
        markRead: true,
        labels: ["Newsletters"],
      },
    },

    // ===== AUTO-FILE RECEIPTS =====
    {
      filter: {
        query: "subject:(receipt OR invoice OR order) has:attachment",
      },
      actions: {
        archive: true,
        labels: ["Reference/Receipts"],
      },
    },

    // ===== GITHUB NOTIFICATIONS =====
    {
      filter: {
        query: "from:notifications@github.com -is:important",
      },
      actions: {
        archive: true,
        labels: ["Notifications"],
      },
    },

    // ===== TEAM COMMUNICATIONS =====
    {
      filter: {
        query: "from:@company.com (subject:standup OR subject:team update)",
      },
      actions: {
        labels: ["Work/Team"],
      },
    },

    // ===== FINANCIAL EMAILS =====
    {
      filter: {
        query: "from:(bank.com OR creditcard.com OR paypal.com)",
      },
      actions: {
        labels: ["Personal/Finance"],
        markImportant: true,
      },
    },
  ],
}
