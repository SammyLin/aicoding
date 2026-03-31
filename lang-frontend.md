# Frontend Standards

This file contains all frontend-specific conventions. Apply these rules when working on a frontend project.

## Framework & Build Tool

```
1. Default stack: React + TypeScript + Vite
2. Use React Router for client-side routing.
3. If the project already uses another framework (Next.js, Vue, Svelte, Angular), follow that framework's conventions.
4. Never mix frameworks in the same project.
```

### New Project Setup

```bash
pnpm create vite my-app --template react-ts
cd my-app
pnpm install
pnpm add react-router-dom @tanstack/react-query
pnpm add -D @testing-library/react @testing-library/user-event jsdom msw
```

## Package Manager: pnpm

Same as lang-node.md. Use pnpm for all operations. Never use npm or yarn.

## Linter & Formatter: ESLint + Prettier

```
1. Install: pnpm add -D eslint prettier typescript-eslint @eslint/js eslint-plugin-react-hooks eslint-plugin-jsx-a11y
2. Create eslint.config.js (flat config)
3. Create .prettierrc
4. Add to package.json scripts:
   "lint": "eslint . && prettier --check .",
   "lint:fix": "eslint --fix . && prettier --write ."
5. Verify: pnpm run lint
```

- Enable `eslint-plugin-react-hooks` — enforce Rules of Hooks.
- Enable `eslint-plugin-jsx-a11y` — catch accessibility issues at lint time.

## Naming Conventions

- Files: `PascalCase.tsx` for components, `camelCase.ts` for utilities/hooks
- Components: `PascalCase` — one component per file, file name matches component name
- Hooks: `useCamelCase` — prefix with `use`, one hook per file
- Types / Interfaces: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- Event handlers: `handleEventName` (e.g., `handleClick`, `handleSubmit`)
- Boolean props: `isActive`, `hasError`, `canSubmit` — use `is/has/can/should` prefix
- Test files: `*.test.tsx` or `*.spec.tsx`, colocated next to source

## File Structure (feature-based)

```
src/
├── features/
│   ├── order/
│   │   ├── types.ts              ← Domain types, Zod schemas
│   │   ├── api.ts                ← API calls (fetch/axios wrapper)
│   │   ├── hooks/
│   │   │   ├── useOrders.ts      ← Data fetching hook
│   │   │   └── useOrderForm.ts   ← Form logic hook
│   │   ├── components/
│   │   │   ├── OrderList.tsx      ← UI component
│   │   │   ├── OrderCard.tsx      ← UI component
│   │   │   └── OrderForm.tsx      ← Form component
│   │   ├── OrderPage.tsx          ← Page component (composes feature)
│   │   ├── OrderPage.test.tsx     ← Page-level tests
│   │   └── index.ts               ← Public exports
│   └── shared/
│       ├── components/            ← Reusable UI components (Button, Modal, etc.)
│       ├── hooks/                 ← Reusable hooks (useDebounce, useLocalStorage, etc.)
│       ├── utils/                 ← Pure utility functions
│       └── types/                 ← Shared types
├── routes.tsx                     ← React Router route definitions
└── main.tsx                       ← Entry point (BrowserRouter + QueryClientProvider)
```

- Organize by feature, not by type. `features/order/` over `components/Order*.tsx`.
- `shared/` is for truly reusable pieces used by 2+ features. Do not put feature-specific code here.
- Each feature folder is self-contained. No cross-feature imports of internal files.

## Component Design

### Rules

- Prefer function components. Never use class components.
- Keep components small — one responsibility per component.
- Split into container (logic) and presentational (UI) when a component exceeds ~100 lines.
- Props type must be defined explicitly. No inline object types in function signatures.
- Use `children` prop for composition instead of prop drilling deeply nested data.

### Pattern

```tsx
// Props defined at the top
interface OrderCardProps {
  order: Order;
  onSelect: (id: string) => void;
}

// Component is a named export (not default)
export function OrderCard({ order, onSelect }: OrderCardProps) {
  return (
    <div onClick={() => onSelect(order.id)}>
      <h3>{order.title}</h3>
      <p>{order.status}</p>
    </div>
  );
}
```

- Named exports only. No `export default`.
- Destructure props in function signature.
- Co-locate styles, tests, and sub-components with their parent.

## State Management

```
1. Local UI state        → useState / useReducer
2. Server state          → TanStack Query (React Query) or SWR
3. Global client state   → Zustand (or Context for simple cases)
4. Form state            → React Hook Form + Zod resolver
5. URL state             → useSearchParams / router query
```

- Do NOT reach for global state when local state suffices.
- Server state (data from API) must go through a data-fetching library. Never store fetched data in useState.
- Avoid prop drilling deeper than 2 levels — extract a hook or use context.

## Data Fetching

- Use TanStack Query (preferred) or SWR for all API data.
- Define API functions in `features/<feature>/api.ts` — pure functions that return promises.
- Wrap in custom hooks in `features/<feature>/hooks/` — components never call API functions directly.

```tsx
// api.ts
export async function fetchOrders(): Promise<Order[]> {
  const res = await fetch("/api/orders");
  if (!res.ok) throw new Error("Failed to fetch orders");
  return res.json();
}

// hooks/useOrders.ts
export function useOrders() {
  return useQuery({ queryKey: ["orders"], queryFn: fetchOrders });
}

// OrderPage.tsx — component only uses the hook
export function OrderPage() {
  const { data: orders, isLoading, error } = useOrders();
  if (isLoading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;
  return <OrderList orders={orders} />;
}
```

## Forms & Validation

- Use React Hook Form for forms with 3+ fields.
- Use Zod for schema validation. Share schemas with backend when possible.
- Always show validation errors inline next to the field.
- Disable submit button during submission. Show loading indicator.

```tsx
const OrderSchema = z.object({
  title: z.string().min(1, "Title is required"),
  quantity: z.number().min(1, "Quantity must be at least 1"),
});

type OrderFormData = z.infer<typeof OrderSchema>;
```

## Styling

```
1. Preferred: Tailwind CSS (utility-first)
2. Alternative: CSS Modules (*.module.css)
3. Avoid: CSS-in-JS runtime libraries (styled-components, emotion) — they add runtime cost.
4. Never use inline styles for anything beyond dynamic values (e.g., calculated widths).
```

- Follow mobile-first responsive design: style for mobile, then add breakpoints for larger screens.
- Use design tokens / CSS variables for colors, spacing, and typography.
- No magic numbers — define spacing/sizing as tokens or Tailwind config.

## Accessibility (a11y)

These are NOT optional:

- All images must have `alt` text. Decorative images use `alt=""`.
- Interactive elements must be keyboard-accessible (focusable, operable via Enter/Space).
- Use semantic HTML: `<button>` for actions, `<a>` for navigation, `<main>`, `<nav>`, `<header>`.
- Forms must have `<label>` associated with each input (use `htmlFor`).
- Color contrast must meet WCAG AA (4.5:1 for text, 3:1 for large text).
- ARIA attributes only when semantic HTML is insufficient. Prefer native elements.
- Manage focus for modals, dialogs, and dynamic content.

## Performance

- Lazy-load routes and heavy components with `React.lazy()` + `Suspense`.
- Memoize expensive computations with `useMemo`. Memoize callbacks with `useCallback` only when passed to memoized children.
- Do NOT prematurely optimize — only memoize when you measure a performance issue.
- Images: use `loading="lazy"` for below-the-fold images.
- Bundle size: audit with `pnpm dlx vite-bundle-visualizer`. Keep initial JS under 200KB gzipped.

## Testing

- Framework: vitest + @testing-library/react.
- Run: `pnpm test`
- Test behavior, not implementation. Query by role/label, never by class name or test-id unless necessary.

### What to test

```
1. Component rendering     → renders correct content given props
2. User interactions       → click, type, submit produce expected outcomes
3. Conditional rendering   → loading, error, empty states show correctly
4. Hook logic              → custom hooks return expected values (use renderHook)
5. Integration             → page-level tests that compose multiple components
```

### Test pattern

```tsx
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { OrderCard } from "./OrderCard";

describe("OrderCard", () => {
  it("calls onSelect with order id when clicked", async () => {
    const onSelect = vi.fn();
    render(<OrderCard order={mockOrder} onSelect={onSelect} />);

    await userEvent.click(screen.getByRole("heading", { name: mockOrder.title }));
    expect(onSelect).toHaveBeenCalledWith(mockOrder.id);
  });
});
```

### Test rules

- Mock API calls with MSW (Mock Service Worker), not by mocking fetch directly.
- Wrap components that use providers (QueryClient, Router, Theme) in a test utility `renderWithProviders`.
- Each test must be independent. No shared mutable state between tests.

## Error Handling

- Every async operation must handle loading, error, and success states.
- Use Error Boundaries for unexpected render errors. Place at route level minimum.
- Show user-friendly error messages. Never expose raw error objects or stack traces in UI.
- Log errors to a monitoring service (Sentry or similar) in production.

## How to Add a Frontend Feature

```
1. Define types               → src/features/<feature>/types.ts (Zod schema + inferred type)
2. Write API functions         → src/features/<feature>/api.ts
3. Write custom hook + test    → src/features/<feature>/hooks/useFeature.ts
4. Write component tests       → src/features/<feature>/components/Component.test.tsx
5. Implement components        → src/features/<feature>/components/Component.tsx
6. Compose page                → src/features/<feature>/FeaturePage.tsx
7. Add route                   → src/routes.tsx
8. Run: pnpm run lint && pnpm test
9. Browser verify              → screenshot at mobile + desktop widths (see harness-engineering.md)
```

## Frontend Verification Checklist

Before reporting any frontend task as done:

- [ ] `pnpm run lint` passes
- [ ] `pnpm test` passes
- [ ] Browser screenshot taken at desktop width
- [ ] Browser screenshot taken at mobile width (if responsive)
- [ ] Keyboard navigation works for interactive elements
- [ ] Loading and error states verified
- [ ] No console errors or warnings
