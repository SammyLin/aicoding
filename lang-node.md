# Node / TypeScript Standards

This file contains all Node.js and TypeScript specific conventions. Apply these rules when working in a Node/TypeScript project.

## Package Manager: pnpm

```
1. pnpm init
2. Use pnpm for all operations:
   pnpm install / pnpm add <pkg> / pnpm add -D <pkg> / pnpm run <script>
3. Commit pnpm-lock.yaml. Never commit node_modules.
4. In Dockerfile: use corepack enable && corepack prepare pnpm@latest --activate
```

- Never use npm or yarn. If the project already uses them, ask the user before migrating.
- Lockfile: `pnpm-lock.yaml` — always commit.

## Linter & Formatter: ESLint + Prettier

```
1. Install: pnpm add -D eslint prettier typescript-eslint @eslint/js
2. Create eslint.config.js (flat config)
3. Create .prettierrc
4. Add to package.json scripts:
   "lint": "eslint . && prettier --check .",
   "lint:fix": "eslint --fix . && prettier --write ."
5. Verify: pnpm run lint
```

## Naming Conventions

- Files: `camelCase.ts` or `kebab-case.ts` (follow existing project pattern)
- Classes / Interfaces / Types: `PascalCase`
- Functions / Variables: `camelCase`
- Constants: `UPPER_SNAKE_CASE`
- Test files: `*.test.ts` or `*.spec.ts`, colocated next to source

## File Structure (feature-based)

```
src/
├── order/
│   ├── types.ts            ← Domain types, Zod schemas
│   ├── repo.ts             ← Data access (interface + implementation)
│   ├── service.ts          ← Business logic
│   ├── controller.ts       ← HTTP handler (Express/Fastify/Hono)
│   ├── service.test.ts     ← Tests (colocated)
│   └── index.ts            ← Public exports for this module
├── shared/
│   ├── config/
│   ├── middleware/
│   └── errors/
└── index.ts                ← Composition root: wire DI, register routes
```

## How to Add an API Endpoint

```
1. Define types         → src/<feature>/types.ts (Zod schema + inferred type)
2. Write service test   → src/<feature>/service.test.ts
3. Implement service    → src/<feature>/service.ts
4. Run test — confirm pass
5. Write controller     → src/<feature>/controller.ts (thin: parse req → call service → format res)
6. Register route       → src/index.ts or src/<feature>/index.ts
7. Run: pnpm run lint && pnpm test
8. Test manually: curl http://localhost:3000/api/<endpoint>
```

## Dependency Injection

Use constructor injection or function parameters. No global singletons.

```typescript
// Define interface
interface OrderRepository {
  getById(id: string): Promise<Order | null>;
}

// Service depends on interface
class OrderService {
  constructor(private repo: OrderRepository) {}

  async getOrder(id: string): Promise<Order> {
    const order = await this.repo.getById(id);
    if (!order) throw new NotFoundError(`Order ${id} not found`);
    return order;
  }
}

// Wire in composition root (src/index.ts)
const repo = new PgOrderRepository(db);
const service = new OrderService(repo);
```

## Error Handling

- Use custom error classes extending `Error`.
- Throw from service layer. Catch and convert to HTTP status in controller only.
- Always include context: what operation failed, why, and relevant IDs.

```typescript
class AppError extends Error {
  constructor(message: string, public statusCode: number = 500) {
    super(message);
  }
}

class NotFoundError extends AppError {
  constructor(message: string) { super(message, 404); }
}
```

## Types & Validation

- Use Zod for runtime validation at boundaries (API input, external data).
- Infer TypeScript types from Zod schemas: `type Order = z.infer<typeof OrderSchema>`
- Strict TypeScript: enable `strict: true` in tsconfig.json.
- No `any`. Use `unknown` and narrow with type guards if needed.

## Testing

- Framework: vitest (preferred) or jest.
- Run: `pnpm test` / `pnpm run test`
- Mock external deps with vitest mocks or dependency injection.
- Test naming: `describe("OrderService")` → `it("returns error when inventory empty")`

## Dockerfile

```dockerfile
FROM node:20-slim AS build
RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app
COPY pnpm-lock.yaml package.json ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm run build

FROM node:20-slim AS runtime
RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/package.json /app/pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prod
USER node
HEALTHCHECK CMD curl -f http://localhost:3000/health || exit 1
CMD ["node", "dist/index.js"]
```
