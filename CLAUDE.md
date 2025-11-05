# Scoutplan Codebase Guide

This document provides comprehensive guidance for AI assistants and developers working with the Scoutplan codebase.

## Project Overview

**Scoutplan** is a web-based event management and communication platform designed for Scout organizations and youth groups. The application enables event scheduling, RSVP management, messaging, document management, payment processing, and member relationship tracking.

### Technology Stack

- **Backend**: Rails 8.0.2 with Ruby 3.4.2
- **Database**: PostgreSQL 13+, Redis (caching/jobs)
- **Frontend**: Server-rendered Slim templates with Stimulus JS and Tailwind CSS
- **Background Jobs**: Sidekiq with sidekiq-scheduler
- **Authentication**: Devise with Google OAuth2
- **Authorization**: Pundit policies
- **Testing**: RSpec with Factory Bot and Capybara

## Architecture

### MVC with Service Objects

The application follows traditional Rails MVC with enhancements:

- **Models** (56+ classes): Rich domain models with concerns and polymorphic associations
- **Controllers** (55+ files): RESTful controllers with nested resources
- **Views** (71+ directories): Slim templates with ViewComponent for reusable UI
- **Background Jobs**: Sidekiq workers for async operations (emails, notifications, reminders)

### Multi-Tenancy

Units act as tenants. Most resources are scoped to `unit_id`. Always filter data by unit membership.

### Key Architectural Patterns

- **Polymorphic Associations**: Documents, locations, tasks, and messages use polymorphic associations
- **Service Objects**: Complex operations delegated to job classes
- **Feature Flags**: Flipper gates features for gradual rollout
- **Async Everything**: Background jobs handle emails, notifications, reminders, digests
- **Authorization Layer**: Pundit policies enforce access control

## Directory Structure

```
/app
├── models/               # Domain models with concerns
├── controllers/          # HTTP request handlers
│   ├── admin/           # Admin namespace
│   ├── settings/        # Settings management
│   └── units/           # Unit-scoped controllers
├── views/               # Slim templates
│   ├── components/      # Reusable UI components
│   └── mailers/         # Email templates
├── jobs/                # Sidekiq background jobs (14+)
├── mailers/             # Email mailer classes (10+)
├── policies/            # Pundit authorization policies
├── notifiers/           # Noticed gem notification classes
├── texters/             # Twilio SMS handlers
├── components/          # ViewComponent classes
│   └── email/          # Email component library
└── javascript/
    ├── controllers/     # Stimulus JS controllers (60+)
    └── channels/        # ActionCable WebSocket channels

/spec                    # RSpec test suite
├── models/              # Model specs
├── features/            # Integration/acceptance tests
├── jobs/                # Background job specs
├── policies/            # Authorization specs
└── factories/           # Factory Bot factories

/db
├── migrate/             # 143 migrations
└── schema.rb           # Current database schema

/config
├── routes.rb           # Application routes
└── initializers/       # Configuration files
```

## Core Domain Models

### Primary Models

- **User**: Platform users with authentication and contact info
- **Unit**: Scout units/troops (tenant root)
- **UnitMembership**: User membership in units with roles (member, admin, event_organizer)
- **Event**: Scheduled events/meetings with recurrence support
- **EventRsvp**: Member attendance responses (attend/decline/maybe)
- **Message**: Unit-scoped messages and announcements
- **Document**: Files attached to units, events, or RSVPs (polymorphic)
- **Location**: Event locations with geocoding
- **Payment**: Stripe payment tracking
- **MemberRelationship**: Family connections (parent-child)

### Important Concerns

Located in `app/models/concerns/`:

- **Contactable**: Shared contact info methods (phone, email)
- **Notifiable**: Notification preference handling
- **Remindable**: Reminder scheduling logic

## Database Schema

### Key Features

- **Polymorphic associations**: `document.documentable`, `location.locatable`, `task.taskable`
- **JSONB columns**: Settings and configuration data
- **Array columns**: Equipment lists, distribution lists
- **Composite unique constraints**: Prevent duplicate memberships
- **Soft deletes**: Status enums (active/inactive)
- **Audit trail**: Paper Trail tracks changes via `versions` table

### Common Scopes

- `active` - Active records only
- `registered` - Registered members
- `for_unit(unit)` - Records for specific unit
- `upcoming` - Future events

## Authentication & Authorization

### Authentication (Devise)

- Database authentication with email/password
- Google OAuth2 integration
- Magic links for passwordless login
- Session-based (no token APIs)

### Authorization (Pundit)

All controllers use Pundit policies. Always check authorization:

```ruby
authorize @event  # In controller action
policy(@event).update?  # Check permission
```

**Policy files**: `app/policies/*_policy.rb`

**Common roles** (in UnitMembership):
- `member` - Basic access
- `admin` - Full unit access
- `event_organizer` - Event management

## Background Jobs

### Job Classes (`app/jobs/`)

- **SendWeeklyDigestJob** - Weekly email digests
- **EventReminderJob** - Event reminders via email/SMS
- **RsvpNagJob** - RSVP follow-up reminders
- **SendMessageJob** - Message delivery
- **ProcessInboundEmailJob** - Mailgun webhook handling

### Scheduling

Recurring jobs configured via sidekiq-scheduler. Check `config/sidekiq.yml` or initializers.

### Job Patterns

```ruby
class MyJob < ApplicationJob
  queue_as :default

  def perform(record_id)
    # Job logic here
    # Errors automatically tracked by Honeybadger
  end
end
```

## Frontend Architecture

### Server-Rendered with Progressive Enhancement

- **Templates**: Slim syntax for concise HTML
- **Interactivity**: Stimulus JS controllers (60+)
- **Navigation**: Turbo Rails for fast page transitions
- **Styling**: Tailwind CSS with custom color system

### Stimulus Controllers (`app/javascript/controllers/`)

Key controllers:
- `event_controller.js` - Event form handling
- `calendar_preferences_controller.js` - Calendar view
- `dropdown_controller.js` - Dropdown menus
- `autocomplete_controller.js` - Autocomplete fields
- `clipboard_controller.js` - Copy to clipboard

### Adding Interactivity

1. Create Stimulus controller in `app/javascript/controllers/`
2. Add data attributes to HTML: `data-controller="my-feature"`
3. Define actions: `data-action="click->my-feature#handleClick"`
4. Access targets: `data-my-feature-target="element"`

## Communication

### Email (Postmark + ActionMailer)

**Mailers** (`app/mailers/`):
- **UnitMailer** - Unit-wide announcements
- **EventMailer** - Event notifications
- **MessageMailer** - Message delivery
- **DigestMailer** - Weekly digests

**Email Components** (`app/components/email/`):
- ViewComponent library for email templates
- Reusable header, footer, button components

### SMS (Twilio)

**Texters** (`app/texters/`):
- Custom classes for SMS notifications
- Twilio client configured in initializers

### Notifications (Noticed Gem)

**Notifiers** (`app/notifiers/`):
- In-app notification system
- Email and SMS delivery channels
- User preferences respected

## Feature Flags (Flipper)

### Active Features

- `:receive_event_publish_notice` - Event publish notifications
- `:receive_bulk_publish_notice` - Bulk publish notifications
- `:receive_rsvp_confirmation` - RSVP confirmations
- `:receive_digest` - Weekly digest emails

### Checking Flags

```ruby
if Flipper.enabled?(:feature_name, current_user)
  # Feature code
end
```

### Admin UI

Access Flipper UI at `/flipper` (admin only)

## Testing Strategy

### RSpec Test Structure

```
/spec
├── models/          # Validations, associations, methods
├── features/        # Full user workflows (Capybara)
├── jobs/           # Background job behavior
├── mailers/        # Email content and delivery
├── policies/       # Authorization rules
├── components/     # ViewComponent rendering
└── factories/      # Test data factories
```

### Running Tests

```bash
# All tests
bundle exec rspec

# Specific file
bundle exec rspec spec/models/event_spec.rb

# Specific line
bundle exec rspec spec/models/event_spec.rb:42
```

### Test Patterns

- Use Factory Bot for test data: `create(:event, unit: unit)`
- Feature specs use Capybara: `visit unit_events_path(unit)`
- Shared examples in `spec/support/shared_examples/`
- VCR cassettes in `spec/fixtures/vcr_cassettes/`

## Development Setup

### Prerequisites

- Docker & Docker Compose
- mkcert (for local HTTPS)
- Required API keys (see below)

### Quick Start

1. Clone repository
2. Create `docker-compose.override.yml` with local DB config
3. Install mkcert and create certificates
4. Add `127.0.0.1 local.scoutplan.org` to `/etc/hosts`
5. Run: `docker-compose up`
6. In separate terminal: `rails tailwindcss:watch`
7. Run migrations: `rails db:migrate`
8. Access app at `https://local.scoutplan.org`

### Docker Services

- **app**: Rails Puma server (port 3000)
- **sidekiq**: Background job processor
- **db**: PostgreSQL 13
- **redis**: Cache and job queue
- **caddy**: HTTPS reverse proxy (ports 80/443)
- **mailcatcher**: Email testing (port 1080)

### Environment Variables

Critical ENV vars (set in `.env` or secrets):

```bash
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
RAILS_MASTER_KEY=...
SECRET_KEY_BASE=...

# External Services
TWILIO_ACCOUNT_SID=...
TWILIO_AUTH_TOKEN=...
POSTMARK_API_TOKEN=...
STRIPE_PUBLISHABLE_KEY=...
STRIPE_SECRET_KEY=...
MAPBOX_ACCESS_TOKEN=...
GOOGLE_PLACES_API_KEY=...
OPENWEATHER_API_KEY=...

# Storage (DigitalOcean Spaces)
DO_SPACES_KEY=...
DO_SPACES_SECRET=...
DO_SPACES_BUCKET=...
DO_SPACES_REGION=...

# Monitoring
HONEYBADGER_API_KEY=...
SCOUT_KEY=...
```

## Common Tasks

### Adding a New Feature

1. **Create model** (if needed):
   ```bash
   rails g model FeatureName field:type unit:references
   rails db:migrate
   ```

2. **Create policy**: Add `app/policies/feature_name_policy.rb`

3. **Create controller**: Add to `app/controllers/` with REST actions

4. **Add routes**: Update `config/routes.rb`

5. **Create views**: Add Slim templates in `app/views/feature_name/`

6. **Add Stimulus controller** (if interactive): `app/javascript/controllers/feature_name_controller.js`

7. **Write tests**: Add specs in `spec/models/`, `spec/policies/`, `spec/features/`

### Adding a Background Job

```ruby
# app/jobs/my_job.rb
class MyJob < ApplicationJob
  queue_as :default

  def perform(record_id)
    record = Record.find(record_id)
    # Do work
  end
end

# Call from controller/model
MyJob.perform_later(record.id)
```

### Adding an Email Template

1. **Create mailer**: `app/mailers/my_mailer.rb`
2. **Add views**: `app/views/my_mailer/notification.html.erb`
3. **Use ViewComponent**: Create component in `app/components/email/`
4. **Add preview**: `spec/mailers/previews/my_mailer_preview.rb`
5. **Test**: Add specs in `spec/mailers/my_mailer_spec.rb`

### Adding Stimulus Interactivity

```javascript
// app/javascript/controllers/my_feature_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output"]

  connect() {
    // Called when controller connects to DOM
  }

  handleClick(event) {
    // Action handler
    this.outputTarget.textContent = "Clicked!"
  }
}
```

```slim
/ app/views/my_view.html.slim
div data-controller="my-feature"
  button data-action="click->my-feature#handleClick" Click me
  div data-my-feature-target="output"
```

## Critical Conventions

### Model Patterns

- Use concerns for shared behavior
- Enable Paper Trail for audit: `has_paper_trail`
- Add validations for data integrity
- Use scopes for common queries
- Define associations explicitly

### Controller Patterns

- Authorize with Pundit: `authorize @resource`
- Use before_actions for setup
- Scope queries to current_unit
- Handle errors gracefully
- Redirect with flash messages

### View Patterns

- Use Slim for templates
- Extract components with ViewComponent
- Add Stimulus for interactivity
- Follow Tailwind utility-first approach
- Keep logic in helpers/presenters

### Authorization Patterns

- Always authorize in controllers
- Check permissions in views: `policy(@record).update?`
- Scope queries with Pundit: `policy_scope(Event)`
- Test policies thoroughly

### Job Patterns

- Jobs should be idempotent
- Pass IDs, not objects
- Handle missing records gracefully
- Use appropriate queues
- Set retry limits for external APIs

## External Integrations

### APIs & Services

- **Twilio**: SMS/text messaging
- **Postmark**: Transactional email
- **Mailgun**: Inbound email parsing
- **Stripe**: Payment processing
- **Google**: OAuth2, Places API
- **OpenWeather**: Weather forecasts
- **Mapbox**: Maps and geocoding
- **OpenAI**: AI features (ruby-openai)

### Webhooks

- **Mailgun**: Inbound email at `/mailgun/inbound`
- **Stripe**: Payment events at `/stripe/webhook`
- **Instagram**: Integration callbacks

## Security Considerations

### Authentication & Authorization

- Devise handles authentication
- Pundit enforces authorization
- Unit-scoped data prevents cross-tenant access
- CSRF protection enabled
- Rack-attack for rate limiting

### Data Protection

- Rails credentials for secrets
- SQL injection prevention via ActiveRecord
- XSS prevention via template escaping
- HTML sanitization for user content
- Session-based authentication

## Common Pitfalls

### Multi-Tenancy

Always scope queries by unit:

```ruby
# BAD
Event.all

# GOOD
current_unit.events
```

### Authorization

Always authorize before actions:

```ruby
# BAD
def update
  @event.update(event_params)
end

# GOOD
def update
  authorize @event
  @event.update(event_params)
end
```

### Background Jobs

Pass IDs, not objects:

```ruby
# BAD
MyJob.perform_later(@event)

# GOOD
MyJob.perform_later(@event.id)
```

### Feature Flags

Check flags before using features:

```ruby
# BAD
NotificationMailer.digest(user).deliver_later

# GOOD
if Flipper.enabled?(:receive_digest, user)
  NotificationMailer.digest(user).deliver_later
end
```

## File Locations by Task

| Task | Location |
|------|----------|
| Add model | `app/models/` + migration in `db/migrate/` |
| Add controller | `app/controllers/` |
| Add view | `app/views/[controller_name]/` |
| Add policy | `app/policies/` |
| Add job | `app/jobs/` |
| Add mailer | `app/mailers/` + views in `app/views/[mailer_name]/` |
| Add Stimulus controller | `app/javascript/controllers/` |
| Add test | `spec/` (mirror `app/` structure) |
| Add route | `config/routes.rb` |
| Add initializer | `config/initializers/` |

## Helpful Commands

```bash
# Development
docker-compose up                    # Start all services
rails tailwindcss:watch             # Watch Tailwind CSS
rails console                       # Rails console
rails db:migrate                    # Run migrations
rails db:reset                      # Reset database

# Testing
bundle exec rspec                   # Run all tests
bundle exec rspec spec/models/      # Run model tests
bundle exec rspec --tag focus       # Run focused tests

# Background Jobs
rails sidekiq                       # Start Sidekiq (if not using Docker)

# Code Quality
bundle exec standardrb              # Run linter
bundle exec standardrb --fix        # Auto-fix linting issues

# Debugging
rails c                             # Console for debugging
rails dbconsole                     # Database console
```

## Resources

- **Rails Guides**: https://guides.rubyonrails.org/
- **Stimulus Handbook**: https://stimulus.hotwired.dev/
- **Tailwind CSS**: https://tailwindcss.com/docs
- **Pundit**: https://github.com/varvet/pundit
- **Sidekiq**: https://github.com/sidekiq/sidekiq
- **ViewComponent**: https://viewcomponent.org/

## Getting Help

- Check existing tests for usage examples
- Review similar features in the codebase
- Consult documentation for gems and libraries
- Ask team members for context-specific guidance

---

**Generated**: November 5, 2025

This guide provides essential information for understanding and working with the Scoutplan codebase effectively.
