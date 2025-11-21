package cmd

import (
	"context"
	"fmt"
	"sort"
	"strings"

	"github.com/spf13/cobra"
	"google.golang.org/api/gmail/v1"
)

var (
	analyzeDays    int
	analyzeMaxMsgs int
	analyzeOutput  string
)

// analyzeCmd represents the analyze command
var analyzeCmd = &cobra.Command{
	Use:   "analyze",
	Short: "Analyze email patterns and suggest filters",
	Long: `The analyze command fetches recent email metadata and analyzes patterns
to suggest filter rules that implement Inbox Zero principles.

It examines senders, subjects, and other metadata to group similar emails
and generate appropriate gmailctl filter rules.

Example:
  gmailctl analyze --days 30 --max 1000`,
	Run: func(*cobra.Command, []string) {
		if err := analyzeEmails(); err != nil {
			fatal(err)
		}
	},
}

func init() {
	rootCmd.AddCommand(analyzeCmd)

	// Flags
	analyzeCmd.PersistentFlags().IntVarP(&analyzeDays, "days", "d", 30, "number of days to analyze")
	analyzeCmd.PersistentFlags().IntVarP(&analyzeMaxMsgs, "max", "m", 1000, "maximum number of messages to analyze")
	analyzeCmd.PersistentFlags().StringVarP(&analyzeOutput, "output", "o", "", "output file for suggested config (default to stdout)")
}

type EmailPattern struct {
	FromDomain string
	FromEmail  string
	Subject    string
	ListID     string
	Count      int
	MessageIDs []string
}

type PatternSuggestion struct {
	Description string
	Query       string
	Actions     []string
	Priority    int
	Category    string // Newsletter, Notification, Receipt, etc.
}

func analyzeEmails() error {
	gmailapi, err := openAPI()
	if err != nil {
		return configurationError(fmt.Errorf("connecting to Gmail: %w", err))
	}

	ctx := context.Background()

	// Fetch recent emails using metadata scope
	fmt.Printf("Fetching emails from the last %d days...\n", analyzeDays)

	query := fmt.Sprintf("newer_than:%dd", analyzeDays)
	patterns, err := fetchAndAnalyzePatterns(ctx, gmailapi.Service, query, analyzeMaxMsgs)
	if err != nil {
		return fmt.Errorf("analyzing emails: %w", err)
	}

	// Generate suggestions based on patterns
	suggestions := generateSuggestions(patterns)

	// Output suggestions
	return outputSuggestions(suggestions)
}

func fetchAndAnalyzePatterns(ctx context.Context, srv *gmail.Service, query string, maxMessages int) ([]EmailPattern, error) {
	patternMap := make(map[string]*EmailPattern)

	req := srv.Users.Messages.List("me").Q(query).MaxResults(int64(maxMessages))

	err := req.Pages(ctx, func(msgList *gmail.ListMessagesResponse) error {
		for _, msg := range msgList.Messages {
			// Fetch message metadata
			fullMsg, err := srv.Users.Messages.Get("me", msg.Id).Format("metadata").Do()
			if err != nil {
				fmt.Printf("Warning: Could not fetch message %s: %v\n", msg.Id, err)
				continue
			}

			// Extract headers
			headers := extractHeaders(fullMsg.Payload.Headers)

			// Categorize based on patterns
			pattern := categorizeEmail(headers)
			pattern.MessageIDs = append(pattern.MessageIDs, msg.Id)

			key := pattern.FromDomain + "|" + pattern.ListID
			if existing, ok := patternMap[key]; ok {
				existing.Count++
				existing.MessageIDs = append(existing.MessageIDs, msg.Id)
			} else {
				pattern.Count = 1
				patternMap[key] = &pattern
			}
		}
		return nil
	})

	if err != nil {
		return nil, fmt.Errorf("fetching messages: %w", err)
	}

	// Convert map to slice and sort by count
	patterns := make([]EmailPattern, 0, len(patternMap))
	for _, p := range patternMap {
		patterns = append(patterns, *p)
	}

	sort.Slice(patterns, func(i, j int) bool {
		return patterns[i].Count > patterns[j].Count
	})

	return patterns, nil
}

func extractHeaders(headers []*gmail.MessagePartHeader) map[string]string {
	result := make(map[string]string)
	for _, h := range headers {
		result[strings.ToLower(h.Name)] = h.Value
	}
	return result
}

func categorizeEmail(headers map[string]string) EmailPattern {
	pattern := EmailPattern{
		FromEmail:  headers["from"],
		Subject:    headers["subject"],
		ListID:     headers["list-id"],
	}

	// Extract domain from email
	if from := headers["from"]; from != "" {
		if idx := strings.LastIndex(from, "@"); idx >= 0 {
			endIdx := strings.Index(from[idx:], ">")
			if endIdx >= 0 {
				pattern.FromDomain = from[idx+1 : idx+endIdx]
			} else {
				pattern.FromDomain = from[idx+1:]
			}
		}
	}

	return pattern
}

func generateSuggestions(patterns []EmailPattern) []PatternSuggestion {
	suggestions := []PatternSuggestion{}

	for _, p := range patterns {
		if p.Count < 5 {
			// Skip patterns that occur less than 5 times
			continue
		}

		suggestion := categorizeSuggestion(p)
		suggestions = append(suggestions, suggestion)
	}

	// Sort by priority
	sort.Slice(suggestions, func(i, j int) bool {
		return suggestions[i].Priority > suggestions[j].Priority
	})

	return suggestions
}

func categorizeSuggestion(p EmailPattern) PatternSuggestion {
	suggestion := PatternSuggestion{
		Priority: p.Count,
	}

	// Detect newsletters
	if p.ListID != "" || strings.Contains(strings.ToLower(p.Subject), "newsletter") {
		suggestion.Category = "Newsletter"
		suggestion.Description = fmt.Sprintf("Auto-archive newsletters from %s (found %d)", p.FromDomain, p.Count)
		if p.ListID != "" {
			suggestion.Query = fmt.Sprintf("list:%s", extractListEmail(p.ListID))
		} else {
			suggestion.Query = fmt.Sprintf("from:@%s", p.FromDomain)
		}
		suggestion.Actions = []string{"archive: true", "markRead: true", "markImportant: false"}
		return suggestion
	}

	// Detect notifications
	if strings.Contains(strings.ToLower(p.FromDomain), "notification") ||
	   strings.Contains(strings.ToLower(p.FromDomain), "noreply") ||
	   strings.Contains(strings.ToLower(p.Subject), "notification") {
		suggestion.Category = "Notification"
		suggestion.Description = fmt.Sprintf("Auto-label notifications from %s (found %d)", p.FromDomain, p.Count)
		suggestion.Query = fmt.Sprintf("from:@%s", p.FromDomain)
		suggestion.Actions = []string{"archive: true", "markRead: true", "markSpam: false"}
		return suggestion
	}

	// Detect receipts
	if strings.Contains(strings.ToLower(p.Subject), "receipt") ||
	   strings.Contains(strings.ToLower(p.Subject), "invoice") ||
	   strings.Contains(strings.ToLower(p.Subject), "order confirmation") {
		suggestion.Category = "Receipt"
		suggestion.Description = fmt.Sprintf("File receipts from %s (found %d)", p.FromDomain, p.Count)
		suggestion.Query = fmt.Sprintf("from:@%s", p.FromDomain)
		suggestion.Actions = []string{"archive: true"}
		return suggestion
	}

	// Default categorization
	suggestion.Category = "Bulk"
	suggestion.Description = fmt.Sprintf("Bulk emails from %s (found %d)", p.FromDomain, p.Count)
	suggestion.Query = fmt.Sprintf("from:@%s", p.FromDomain)
	suggestion.Actions = []string{"markImportant: false"}

	return suggestion
}

func extractListEmail(listID string) string {
	// List-ID format: "Name <list-email@domain.com>"
	start := strings.Index(listID, "<")
	end := strings.Index(listID, ">")
	if start >= 0 && end > start {
		return listID[start+1 : end]
	}
	return listID
}

func outputSuggestions(suggestions []PatternSuggestion) error {
	if len(suggestions) == 0 {
		fmt.Println("No significant patterns found.")
		return nil
	}

	fmt.Printf("\n=== Suggested Filters (based on Inbox Zero principles) ===\n\n")
	fmt.Printf("Found %d patterns to consider:\n\n", len(suggestions))

	// Group by category
	categories := make(map[string][]PatternSuggestion)
	for _, s := range suggestions {
		categories[s.Category] = append(categories[s.Category], s)
	}

	// Output by category
	categoryOrder := []string{"Newsletter", "Notification", "Receipt", "Bulk"}

	for _, cat := range categoryOrder {
		if items, ok := categories[cat]; ok {
			fmt.Printf("## %s (%d items)\n\n", cat, len(items))
			for _, s := range items {
				fmt.Printf("- %s\n", s.Description)
				fmt.Printf("  Filter: { query: \"%s\" }\n", s.Query)
				fmt.Printf("  Actions: { %s }\n\n", strings.Join(s.Actions, ", "))
			}
		}
	}

	fmt.Println("\nTo generate a config file from these suggestions, copy the rules into your")
	fmt.Println("~/.gmailctl/config.jsonnet file and adjust as needed.")
	fmt.Println("\nRun 'gmailctl diff' to preview changes before applying.")

	return nil
}
