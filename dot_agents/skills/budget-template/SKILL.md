---
name: budget-template
description: Use when asked to generate Actual Budget #template or #goal lines from a natural-language budgeting description, or to validate/translate goal-template syntax.
---

# Budget Template (Actual)

## Overview
Create **exact Actual Budget goal/template syntax** (`#template` / `#goal`) from a plain-language description. Output only valid template lines—no invented formats.

## When to Use
- User asks for “budget template,” “goal template,” or “Actual Budget template” lines
- Request includes recurring amounts, caps, dates, repeats, percentages, schedules, averages, or remainders
- User needs exact syntax or validation for category note templates

## Core Pattern
1) Identify template type from the description (simple/by/periodic/percent/schedule/average/copy/remainder/goal).  
2) Fill required fields exactly (amounts, dates, names).  
3) Output **only** the template lines in a code block.

### Clarify only when required inputs are missing
Ask only if a required field is missing (e.g., schedule **name**, start date, or target date). Otherwise, produce the exact line.

## Quick Reference (Syntax)

**Simple / limits**
- `#template 50`
- `#template 50 up to 300`
- `#template up to 150`
- `#template up to 150 hold`
- `#template up to 100 per week starting 2024-10-07`

**By (save by date)**
- `#template 500 by 2025-12`
- `#template 500 by 2025-12 repeat every year`
- `#template 500 by 2025-12 spend from 2025-11`

**Periodic**
- `#template 10 repeat every 2 weeks starting 2025-01-04`
- `#template 10 repeat every week starting 2025-01-06 up to 55`

**Percent**
- `#template 10% of all income`
- `#template 10% of previous Paycheck`
- `#template 10% of available funds`

**Schedule**
- `#template schedule Internet`
- `#template schedule full Simplefin`
- `#template schedule Insurance [increase 20%]`

**Average / Copy / Remainder**
- `#template average 6 months`
- `#template average 3 months [increase 10%]`
- `#template copy from 12 months ago`
- `#template remainder`
- `#template remainder 2 up to 40`

**Goal directive**
- `#goal 500`

## Implementation Notes (Must Follow)
- **Single line per template** (no line breaks within a template).
- **No currency symbols.** Use plain numbers (e.g., `100`, `72.99`).
- **Decimal dot only** (no commas; no thousands separators).
- **Dates:**
  - `by` uses `YYYY-MM`.
  - `starting` uses `YYYY-MM-DD`.
- **Only one `up to` per category.** If any line uses `up to`, the whole category is limited.
- **Schedule names must match exactly** as defined in Schedules.
- Priorities: `#template-1` runs after priority 0; negative priorities are invalid.

## Example
**Request:** “Budget 10% of previous month’s Paycheck and set a long‑term goal of 500.”

```
#template 10% of previous Paycheck
#goal 500
```

## Common Mistakes (Avoid)
- Inventing YAML/YNAB/CSV formats instead of `#template` lines.
- Omitting required date formats (e.g., missing `YYYY-MM` / `YYYY-MM-DD`).
- Adding currency symbols or commas (e.g., `$1,200`).
- Asking clarifying questions when all inputs are already provided.
- Using schedule adjustments without a schedule name.
