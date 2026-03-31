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

## Dockerfile

```dockerfile
FROM golang:1.23-alpine AS build
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /server ./cmd/server

FROM alpine:3.19 AS runtime
RUN adduser -D appuser
COPY --from=build /server /server
USER appuser
HEALTHCHECK CMD wget -qO- http://localhost:8080/health || exit 1
CMD ["/server"]
```
