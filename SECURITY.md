# Security Policy

## Supported versions

Security updates are applied to the latest production release of **Böl** (the version on [Google Play](https://play.google.com/store/apps/details?id=com.japegomez.meal_planner) and the [App Store](https://apps.apple.com/es/app/b%C3%B6l/id6785110375)) and to the `main` branch of this repository.

| Version | Supported |
| --- | --- |
| Latest store release (`main`) | Yes |
| Older store builds | No — please update the app |
| `develop` / feature branches | Fixes land here first; not a supported production channel |

## Reporting a vulnerability

**Do not** open a public GitHub issue, discussion, or pull request for a security problem.

Report it privately with [GitHub private vulnerability reporting](https://github.com/Japegomez/Bol/security/advisories/new) on this repository.

Please include:

- Affected app version, git tag, or commit
- A short description of the issue and why it is security-sensitive
- Steps to reproduce (or a minimal proof of concept)
- Impact (for example: read another user’s private recipes, join a household without an invite, bypass AI quotas)
- Any idea for a fix, if you have one

You should get an acknowledgement within **3 business days**. If the report is confirmed, we will work on a fix and coordinate disclosure with you. If it is declined, we will explain why.

## Scope

In scope, among other things:

- Authentication and session handling
- Supabase Row Level Security, RPCs, and Storage policies
- Household membership and invite codes
- Private recipe share links
- Exposure of secrets or API keys in the client
- Abuse of Edge Functions (recipe assistant, translation, image moderation)

Out of scope:

- Social engineering, physical access, or stolen devices
- Denial of service against third-party providers (Supabase, Google, stores)
- Bugs that only affect outdated app versions already replaced in the stores
- Missing security headers or best-practice nits with no practical impact

## Safe harbor

If you report in good faith, follow this policy, and avoid privacy harm, data destruction, and service disruption, we will not pursue legal action related to the report.
