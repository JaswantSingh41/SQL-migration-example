# SQL Migration and Seeding Project

This project demonstrates the use of SQL migrations for managing database schema changes and seeding data in a PostgreSQL database. It covers concepts like one-to-one, one-to-many, many-to-many relationships, referential integrity, and constraints. The project uses dbmate for managing migrations and applying schema changes.

## Features

- **One-to-One Relationship** between users and user_profiles
- **One-to-Many Relationship** between projects and tasks
- **Many-to-Many Relationship** between users and projects through the project_members table
- **Referential Integrity**:
  - **CASCADE**: Deleting a parent record automatically deletes the related child records
  - **RESTRICT**: Prevents deletion of a record if there are dependent child records
  - **SET NULL**: Sets the foreign key to NULL when the referenced record is deleted
  - **SET DEFAULT**: Sets the foreign key to a default value when the referenced record is deleted
- **Constraints**:
  - **UNIQUE**: Ensures values are unique across records
  - **NOT NULL**: Ensures that a field cannot be empty
  - **CHECK**: Validates that data meets specific conditions

## Project Setup

### Prerequisites

Before running this project, you must have the following installed:

- Node.js (for managing migrations)
- PostgreSQL (for the database)
- dbmate (for managing database migrations)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/JaswantSingh41/SQL-migration-example.git
   cd sql-migration-example
   ```

2. Install dependencies:
   ```bash
     npm install --save-dev dbmate
     npx dbmate --help
   ```

3. Set up environment variables:
   Create a `.env` file in the root directory with the following content:
   ```
 DATABASE_URL=postgres://username:password@localhost:5432/Migrations
   ```

4. Install dbmate (if not installed globally):
   ```bash
   brew install dbmate  # macOS
   ```
   Or, use npx to run dbmate without installing it globally:
   ```bash
   npx dbmate --help
   ```

## Running Migrations

- Run migrations to apply schema changes:
  ```bash
  npx dbmate up
  ```

- Rollback migrations (if you need to undo changes):
  ```bash
  npx dbmate down
  ```

## Seeding Data

- Run seeding migrations after running the main migrations:
  ```bash
  npx dbmate up
  ```

## Viewing the Database

You can view your PostgreSQL database with tools like pgAdmin or DBeaver, or you can use the psql command-line tool to query the database directly.

## Code Examples for Migration Files

### Create Users Table:
```sql
-- 20230513045516_create_user_table.sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL UNIQUE, 
    full_name TEXT NOT NULL, 
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP, 
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

### Create User Profiles Table (One-to-One):
```sql
-- 20230513055516_create_user_profiles_table.sql
CREATE TABLE user_profiles (
    user_id UUID PRIMARY KEY REFERENCES users ON DELETE CASCADE,  -- One-to-One relationship
    avatar_url TEXT,
    bio TEXT,
    phone TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

### Create Projects Table (One-to-Many):
```sql
-- 20230513065516_create_projects_table.sql
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    status project_status NOT NULL DEFAULT 'active',
    owner_id UUID NOT NULL REFERENCES users ON DELETE RESTRICT,  -- Owner of the project
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

### Create Tasks Table (One-to-Many):
```sql
-- 20230513075516_create_tasks_table.sql
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects ON DELETE CASCADE,  -- One-to-Many relationship
    title TEXT NOT NULL,
    description TEXT,
    priority INTEGER NOT NULL DEFAULT 1 CHECK (priority BETWEEN 1 AND 5),
    status task_status NOT NULL DEFAULT 'pending',
    due_date DATE,
    assigned_to UUID REFERENCES users ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

### Create Project Members Table (Many-to-Many):
```sql
-- 20230513085516_create_project_members_table.sql
CREATE TABLE project_members (
    project_id UUID NOT NULL REFERENCES projects ON DELETE CASCADE,  -- Many-to-Many relationship
    user_id UUID NOT NULL REFERENCES users ON DELETE CASCADE,
    role member_role NOT NULL DEFAULT 'member',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (project_id, user_id)
);
```

## Referential Integrity

Referential Integrity ensures that relationships between tables are maintained correctly. It defines how foreign key relationships behave when the referenced data is changed.

### CASCADE:
Deletes related records in the child table when the parent record is deleted.

Example: When a project is deleted, all tasks related to that project will be deleted automatically.
```sql
CREATE TABLE tasks (
    project_id UUID NOT NULL REFERENCES projects ON DELETE CASCADE
);
```

### RESTRICT:
Prevents the deletion of a parent record if there are any related child records.

Example: You cannot delete a user if they are still the owner of a project.
```sql
CREATE TABLE projects (
    owner_id UUID NOT NULL REFERENCES users ON DELETE RESTRICT
);
```

### SET NULL:
Sets the foreign key to NULL when the referenced parent record is deleted.

Example: If a user is deleted, the assigned_to field in tasks is set to NULL.
```sql
CREATE TABLE tasks (
    assigned_to UUID REFERENCES users ON DELETE SET NULL
);
```

### SET DEFAULT:
Sets the foreign key to its default value when the referenced parent record is deleted.

Example: You can set a default value for a field like role in the project_members table.
```sql
CREATE TABLE project_members (
    role member_role NOT NULL DEFAULT 'member'
);
```

## Constraints

### UNIQUE:
Ensures that the values in a column are unique.

Example: email in the users table must be unique:
```sql
CREATE TABLE users (
    email TEXT NOT NULL UNIQUE
);
```

### NOT NULL:
Ensures that a column cannot have a NULL value.

Example: full_name in the users table cannot be NULL:
```sql
CREATE TABLE users (
    full_name TEXT NOT NULL
);
```

### CHECK:
Ensures that values in a column meet certain conditions.

Example: The priority of tasks must be between 1 and 5:
```sql
CREATE TABLE tasks (
    priority INTEGER NOT NULL CHECK (priority BETWEEN 1 AND 5)
);
```
