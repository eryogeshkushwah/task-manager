# Task Manager API

A production-grade RESTful Task Management System built with Ruby on Rails 8 and PostgreSQL. This project is configured as an API-only application, making it lightweight and highly suitable for Dockerization, CI/CD pipelines, and cloud deployments (AWS).

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Folder Structure](#folder-structure)
- [Local Setup & Installation](#local-setup--installation)
- [Database Setup](#database-setup)
- [Running the Application](#running-the-application)
- [Seed Data](#seed-data)
- [API Reference](#api-reference)
  - [Authentication](#authentication)
  - [Dashboard](#dashboard)
  - [Projects](#projects)
  - [Tasks](#tasks)

---

## Features

- **Authentication**: Secure registration, login, and token-based multi-session tracking.
- **Projects**: CRUD operations for projects, strictly scoped to the authenticated owner.
- **Tasks**:
  - Full CRUD operations.
  - User assignment and status transition triggers.
  - Complex search, filter, and sorting.
  - Off-set pagination with metadata.
- **Dashboard**: Live metrics of projects, tasks, pending tasks, in-progress tasks, and completed tasks.
- **Design Patterns**: Encapsulated queries via Query Objects and encapsulated business logic via Service Objects.

---

## Tech Stack

- **Framework**: Ruby on Rails 8.1.x (API-only mode)
- **Runtime**: Ruby 3.2.1+
- **Database**: PostgreSQL

---

## Folder Structure

Below is the simplified structure highlighting the architectural components of this application:

```
task_manager/
├── app/
│   ├── controllers/
│   │   ├── concerns/
│   │   │   └── authenticatable.rb      # HTTP Token auth concern
│   │   ├── application_controller.rb   # Global exception handling & filters
│   │   ├── authentication_controller.rb # Sign up, sign in, sign out
│   │   ├── dashboard_controller.rb     # Summary statistics
│   │   ├── projects_controller.rb      # RESTful Project API
│   │   └── tasks_controller.rb         # RESTful Task API + status actions
│   ├── models/
│   │   ├── project.rb                  # Project model & validations
│   │   ├── session.rb                  # Auth session & secure token
│   │   ├── task.rb                     # Task model, enums & completion callbacks
│   │   └── user.rb                     # User model, secure password & JSON filter
│   ├── queries/
│   │   └── tasks_query.rb              # Query Object for task search/filter/sort/pagination
│   └── services/
│       ├── authentication/
│       │   ├── login_service.rb        # User credential verification & token creation
│       │   └── register_service.rb     # Sign up transaction & project provisioning
│       └── service_result.rb           # Unified service output model
├── config/
│   ├── database.yml                    # PostgreSQL settings
│   ├── routes.rb                       # API routes mapping
│   └── initializers/
│       └── cors.rb                     # CORS origin configuration
└── db/
    ├── migrate/                        # Active Record database migrations
    └── seeds.rb                        # Faker-based seed data generator
```

---

## Local Setup & Installation

### Prerequisites
Make sure you have Ruby 3.x and PostgreSQL installed and running locally.

1. **Clone the repository and navigate to the directory**:
   ```bash
   cd task_manager
   ```

2. **Install project dependencies**:
   ```bash
   bundle install
   ```

---

## Database Setup

1. **Configure credentials**:
   Open [config/database.yml](file:///home/t4/Documents/task_manager/config/database.yml) and configure your database username and password under `default: &default`. Currently, it is set to:
   ```yaml
   username: postgres
   password: postgres
   host: localhost
   ```

2. **Create the databases**:
   ```bash
   bin/rails db:create
   ```

3. **Run database migrations**:
   ```bash
   bin/rails db:migrate
   ```

---

## Seed Data

To populate your database with realistic mockup data for testing, run the seed task:
```bash
bin/rails db:seed
```

This script will clear out old database records and generate:
- **10 Users**: (includes a default tester account: `demo@example.com` with password `password`).
- **20 Projects**: Randomly distributed among users.
- **200 Tasks**: Distributed across projects with varying statuses (`pending`, `in_progress`, `completed`), priorities (`low`, `medium`, `high`), due dates, and completion timestamps.

---

## Running the Application

Start the local development server:
```bash
bin/rails server
```
By default, the server runs on port 3000. You can verify it is healthy by requesting the health check endpoint:
```bash
curl -I http://localhost:3000/up
```

---

## API Reference

All requests must set `Content-Type: application/json` and `Accept: application/json`.
For authenticated routes, you must provide the session token in the authorization header:
`Authorization: Bearer <session_token>`

---

### Authentication

#### 1. Register a new user
- **Endpoint**: `POST /auth/register`
- **Request Body**:
  ```json
  {
    "user": {
      "name": "Jane Doe",
      "email": "jane.doe@example.com",
      "password": "securepassword",
      "password_confirmation": "securepassword"
    }
  }
  ```
- **Response** (201 Created):
  ```json
  {
    "message": "User registered successfully.",
    "user": {
      "id": 11,
      "name": "Jane Doe",
      "email": "jane.doe@example.com",
      "created_at": "2026-07-01T14:00:00.000Z",
      "updated_at": "2026-07-01T14:00:00.000Z"
    }
  }
  ```

#### 2. Log In
- **Endpoint**: `POST /auth/login`
- **Request Body**:
  ```json
  {
    "email": "demo@example.com",
    "password": "password"
  }
  ```
- **Response** (200 OK):
  ```json
  {
    "message": "Login successful.",
    "token": "a1b2c3d4e5f6g7h8i9j0",
    "user": {
      "id": 1,
      "name": "Demo User",
      "email": "demo@example.com",
      "created_at": "2026-07-01T13:40:00.000Z",
      "updated_at": "2026-07-01T13:40:00.000Z"
    }
  }
  ```

#### 3. Log Out
- **Endpoint**: `DELETE /auth/logout`
- **Headers**: `Authorization: Bearer <session_token>`
- **Response** (200 OK):
  ```json
  {
    "message": "Logged out successfully."
  }
  ```

---

### Dashboard

#### 1. Fetch Summary Statistics
- **Endpoint**: `GET /dashboard`
- **Headers**: `Authorization: Bearer <session_token>`
- **Response** (200 OK):
  ```json
  {
    "total_projects": 2,
    "total_tasks": 24,
    "pending_tasks": 8,
    "in_progress_tasks": 6,
    "completed_tasks": 10
  }
  ```

---

### Projects

All projects are isolated per user; clients can only query and modify projects belonging to the logged-in user.

#### 1. List Projects
- **Endpoint**: `GET /projects`
- **Headers**: `Authorization: Bearer <session_token>`
- **Response** (200 OK):
  ```json
  [
    {
      "id": 1,
      "name": "Default Project",
      "description": "Default project created upon registration.",
      "user_id": 1,
      "created_at": "2026-07-01T13:40:00.000Z",
      "updated_at": "2026-07-01T13:40:00.000Z"
    }
  ]
  ```

#### 2. Create Project
- **Endpoint**: `POST /projects`
- **Headers**: `Authorization: Bearer <session_token>`
- **Request Body**:
  ```json
  {
    "project": {
      "name": "Mobile Application Development",
      "description": "Backend API construction for the mobile team."
    }
  }
  ```
- **Response** (201 Created)

#### 3. Get Project Details
- **Endpoint**: `GET /projects/:id`
- **Headers**: `Authorization: Bearer <session_token>`
- **Response** (200 OK)

#### 4. Update Project
- **Endpoint**: `PUT/PATCH /projects/:id`
- **Headers**: `Authorization: Bearer <session_token>`
- **Request Body**:
  ```json
  {
    "project": {
      "name": "Updated Project Name"
    }
  }
  ```
- **Response** (200 OK)

#### 5. Delete Project
- **Endpoint**: `DELETE /projects/:id`
- **Headers**: `Authorization: Bearer <session_token>`
- **Response** (200 OK):
  ```json
  {
    "message": "Project deleted successfully."
  }
  ```

---

### Tasks

All task queries are secured so that users only have access to tasks belonging to their owned projects.

#### 1. List Tasks (Supports Search, Filtering, Sorting, and Pagination)
- **Endpoint**: `GET /tasks`
- **Headers**: `Authorization: Bearer <session_token>`
- **Optional Query Parameters**:
  - **Search**: `search=refactor` (matches `title` or `description`)
  - **Filter by Project**: `project_id=2`
  - **Filter by Assignee**: `assigned_user_id=5` or `assigned_user_id=unassigned` (for tasks not assigned to anyone)
  - **Filter by Status**: `status=pending` (options: `pending`, `in_progress`, `completed`)
  - **Filter by Priority**: `priority=high` (options: `low`, `medium`, `high`)
  - **Filter by Due Date**: `due_date=2026-07-31`
  - **Sort**: `sort_by=due_date` (options: `title`, `status`, `priority`, `due_date`, `completed_at`, `created_at`), default: `created_at`
  - **Sort Direction**: `sort_dir=asc` (options: `asc`, `desc`), default: `desc`
  - **Page**: `page=1` (default: 1)
  - **Per Page**: `per_page=15` (default: 20, max limit: 100)
- **Response** (200 OK):
  ```json
  {
    "tasks": [
      {
        "id": 142,
        "title": "Refactor User Login Flow",
        "description": "Extract controller logics into Auth service.",
        "status": "pending",
        "priority": "high",
        "due_date": "2026-07-15",
        "completed_at": null,
        "project_id": 2,
        "assigned_user_id": 1,
        "created_at": "2026-07-01T13:45:00.000Z",
        "updated_at": "2026-07-01T13:45:00.000Z",
        "project": {
          "id": 2,
          "name": "Mobile Application Development"
        },
        "assigned_user": {
          "id": 1,
          "name": "Demo User",
          "email": "demo@example.com"
        }
      }
    ],
    "meta": {
      "current_page": 1,
      "per_page": 20,
      "total_count": 1,
      "total_pages": 1
    }
  }
  ```

#### 2. Create Task
- **Endpoint**: `POST /tasks`
- **Headers**: `Authorization: Bearer <session_token>`
- **Request Body** (Note: `project_id` must belong to the logged-in user):
  ```json
  {
    "task": {
      "title": "Configure SSL Certs",
      "description": "Establish HTTPS parameters on Puma.",
      "status": "in_progress",
      "priority": "high",
      "due_date": "2026-07-10",
      "project_id": 1,
      "assigned_user_id": 3
    }
  }
  ```
- **Response** (201 Created)

#### 3. Update Task
- **Endpoint**: `PUT/PATCH /tasks/:id`
- **Headers**: `Authorization: Bearer <session_token>`
- **Request Body**:
  ```json
  {
    "task": {
      "priority": "medium",
      "assigned_user_id": null
    }
  }
  ```
- **Response** (200 OK)

#### 4. Delete Task
- **Endpoint**: `DELETE /tasks/:id`
- **Headers**: `Authorization: Bearer <session_token>`
- **Response** (200 OK)

#### 5. Mark Task Complete
- **Endpoint**: `PATCH /tasks/:id/complete`
- **Headers**: `Authorization: Bearer <session_token>`
- **Response** (200 OK) (Updates `status` to `completed` and sets `completed_at` timestamp):
  ```json
  {
    "message": "Task marked as completed.",
    "task": {
      "id": 142,
      "title": "Refactor User Login Flow",
      "status": "completed",
      "completed_at": "2026-07-01T15:02:14.341Z"
    }
  }
  ```

#### 6. Change Task Status
- **Endpoint**: `PATCH /tasks/:id/status`
- **Headers**: `Authorization: Bearer <session_token>`
- **Request Body**:
  ```json
  {
    "status": "in_progress"
  }
  ```
- **Response** (200 OK)
