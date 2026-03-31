# Go Standards

This file contains all Go specific conventions. Apply these rules when working in a Go project.

## Package Manager: go mod

```
1. go mod init <module-path>
2. Use go mod for all operations:
   go get <pkg> / go mod tidy
3. Commit go.mod and go.sum.
```

- Lockfile: `go.sum` — always commit.

## Linter & Formatter: golangci-lint + gofmt

```
1. Install: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
2. Create .golangci.yml with enabled linters:
   linters:
     enable:
       - govet
       - errcheck
       - staticcheck
       - unused
       - gosimple
       - ineffassign
       - gocritic
3. Add to Makefile:
   lint-local: golangci-lint run ./... && go vet ./...
   fmt: gofmt -w .
4. Verify: golangci-lint run ./...
```

- Format: `gofmt` is the standard. Run `gofmt -w .` before commit.
- Go has no separate formatter config — `gofmt` is non-negotiable.

## Naming Conventions

- Files: `snake_case.go`
- Exported (public): `PascalCase` — functions, types, constants, methods
- Unexported (private): `camelCase`
- Interfaces: named by behavior, e.g., `Reader`, `OrderRepository`
- Test files: `*_test.go`, colocated next to source

## File Structure (feature-based)

```
cmd/
└── server/
    └── main.go              ← Entry point: wire DI, start server
internal/
├── order/
│   ├── model.go             ← Domain types (pure structs, no I/O)
│   ├── repository.go        ← Interface + implementation
│   ├── service.go           ← Business logic
│   ├── handler.go           ← HTTP handler
│   └── service_test.go      ← Tests (colocated)
├── inventory/
│   └── ...
└── shared/
    ├── config/
    ├── middleware/
    └── errors/
```

## How to Add an API Endpoint

```
1. Define types         → internal/<feature>/model.go
2. Write service test   → internal/<feature>/service_test.go
3. Implement service    → internal/<feature>/service.go
4. Run test — confirm pass: go test ./internal/<feature>/...
5. Write handler        → internal/<feature>/handler.go (thin: decode → call service → encode)
6. Register route       → cmd/server/main.go or internal/router.go
7. Run: golangci-lint run ./... && go test ./...
8. Test manually: curl http://localhost:8080/api/<endpoint>
```

## Dependency Injection (constructor injection)

Define interfaces at the consumer side. Inject via constructor.

```go
// Interface defined by consumer
type OrderRepository interface {
    GetByID(ctx context.Context, id string) (*Order, error)
}

// Service depends on interface
type OrderService struct {
    repo     OrderRepository
    notifier Notifier
}

func NewOrderService(repo OrderRepository, notifier Notifier) *OrderService {
    return &OrderService{repo: repo, notifier: notifier}
}

func (s *OrderService) GetOrder(ctx context.Context, id string) (*Order, error) {
    order, err := s.repo.GetByID(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("get order %s: %w", id, err)
    }
    if order == nil {
        return nil, NewNotFoundError(fmt.Sprintf("order %s not found", id))
    }
    return order, nil
}
```

- Wire everything in `cmd/server/main.go` (composition root).
- Keep interfaces small: 1-3 methods.
- Define interfaces at the consumer side, not the provider side.

## Error Handling

- Always wrap errors with context: `fmt.Errorf("operation context: %w", err)`
- Never `panic` for expected failures. Reserve panic for truly unrecoverable bugs.
- Use sentinel errors or custom error types for domain errors.
- Handlers convert domain errors to HTTP status codes.

```go
type AppError struct {
    Message    string
    StatusCode int
    Err        error
}

func (e *AppError) Error() string { return e.Message }
func (e *AppError) Unwrap() error { return e.Err }

func NewNotFoundError(msg string) *AppError {
    return &AppError{Message: msg, StatusCode: 404}
}
```

## Types & Interfaces

- All function parameters and returns must have explicit types.
- Use `context.Context` as the first parameter for any I/O operation.
- Avoid `interface{}` / `any` — use generics or concrete types.
- Validate input at handler layer. Domain types are trusted.

## Testing

- Framework: built-in `testing` package.
- Run: `go test ./...`
- Table-driven tests for functions with multiple cases.
- Mock with interfaces + test doubles (hand-written or testify/mock).
- Test naming: `TestOrderService_GetOrder_ReturnsErrorWhenNotFound`

```go
func TestOrderService_GetOrder_ReturnsErrorWhenNotFound(t *testing.T) {
    repo := &mockRepo{getByID: func(ctx context.Context, id string) (*Order, error) {
        return nil, nil
    }}
    svc := NewOrderService(repo, &mockNotifier{})

    _, err := svc.GetOrder(context.Background(), "123")
    if err == nil {
        t.Fatal("expected error, got nil")
    }
}
```

## i18n (Internationalization)

If the project requires multilingual support, choose a framework based on your needs:

| Framework | Best For | Key Trait |
|---|---|---|
| **go-i18n** | General-purpose translation | Most popular, TOML/JSON/YAML message files, CLDR plural rules |
| **golang.org/x/text** | Locale-aware formatting | Official Go package, number/date/currency formatting |
| **gotext** | gettext ecosystem | GNU gettext-compatible (.po/.mo), familiar workflow |
| **spreak** | Modern gettext + type safety | Built on x/text, supports multiple catalog formats |

**Default recommendation:** `go-i18n` for string translation. Supplement with `golang.org/x/text` if you need locale-aware number/date formatting.

```
1. Install: go get github.com/nicksnyder/go-i18n/v2
2. Create a locale directory: locales/{en,zh-TW,...}.toml (or .json/.yaml)
3. Extract all user-facing strings into message IDs from the start.
4. Never hardcode user-facing strings — always use localizer.MustLocalize() or equivalent.
5. Set up language detection middleware (Accept-Language header or user preference).
6. Use goi18n CLI to extract and merge translation files.
```

## Dockerfile

```dockerfile
# --- Build stage ---
FROM golang:1.23-alpine AS build
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /server ./cmd/server

# --- Runtime stage ---
FROM gcr.io/distroless/static-debian12 AS runtime
COPY --from=build /server /server
USER nonroot:nonroot
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD ["/server", "--healthcheck"]
CMD ["/server"]
```

### Key points

- **`distroless`**: No shell, no package manager, no OS utilities — minimal attack surface (~2MB base vs ~7MB alpine). Use `debug` tag temporarily if you need to exec into the container.
- **`-ldflags="-s -w"`**: Strips symbol table and DWARF debug info — typically 20-30% smaller binary.
- **`nonroot`**: Distroless images ship with a built-in `nonroot` user (UID 65534).
- **Self-contained healthcheck**: Since distroless has no shell, implement a `--healthcheck` flag in your Go binary that performs an HTTP call to `/health` and exits with the appropriate code. Example:

```go
// In cmd/server/main.go
if len(os.Args) > 1 && os.Args[1] == "--healthcheck" {
    resp, err := http.Get("http://localhost:8080/health")
    if err != nil || resp.StatusCode != 200 {
        os.Exit(1)
    }
    os.Exit(0)
}
```
